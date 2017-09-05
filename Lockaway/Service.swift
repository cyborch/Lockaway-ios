//
//  Service.swift
//  Lockaway
//
//  Created by Anders Borch on 8/31/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import Starscream
import LockMessage
import ReachabilitySwift

//fileprivate let secure = ""
//fileprivate let host = "localhost:3000"

fileprivate let secure = "s"
fileprivate let host = "jsonpipe.cyborch.com"


class Service: NSObject {
    
    @IBOutlet var controller: LockController? {
        didSet {
            controller?.showLoading()
        }
    }
    
    let socket: WebSocket = {
        log.debug("Creating socket /pipe/\(SocketID.string)")
        let socket = WebSocket(url: URL(string: "ws\(secure)://\(host)/pipe/\(SocketID.string)")!)
        socket.headers["Authorization"] = "Token v33gF7yxN6AUka1GjHhC15029130127920E2ZBAONga0PvMTquVkY"
        return socket
    }()
    
    let reach = Reachability()!

    @IBOutlet var delegate: NSObject? {
        didSet {
            if let delegate = self.delegate as? WebSocketDelegate {
                socket.delegate = delegate
            } else {
                log.error("Delegate \(String(describing: delegate)) is not a WebSocketDelegate")
            }
            
            reach.whenReachable = { _ in
                DispatchQueue.main.async {
                    self.socket.connect()
                }
            }
            socket.connect()
        }
    }

    func sendLockMessage(source: LockMessage.Source) {
        let message = LockMessage(source: source)
        guard let data = message.toData() else {
            log.error("Could not serialize lock message")
            return
        }
        socket.write(data: data)
    }
    
    @IBAction func sendLockMessage() {
        sendLockMessage(source: .button)
    }
    
    static func register(deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        var request = URLRequest(url: URL(string: "http\(secure)://\(host)/device")!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        let post = "pipe_identifier=/pipe/\(SocketID.string)&device_token=\(deviceTokenString)"
        guard let postData = post.data(using: .ascii) else { return }
        request.allHTTPHeaderFields = [
            "Authorization": "Token v33gF7yxN6AUka1GjHhC15029130127920E2ZBAONga0PvMTquVkY",
            "Content-Type": "application/x-www-form-urlencoded",
            "Content-Length": "\(postData.count)"
        ]
        request.httpBody = postData
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                log.error("Error registering device token: \(error!)")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            guard statusCode < 300 else {
                log.error("Unexpected server response: \((response as! HTTPURLResponse).statusCode)")
                return
            }
            log.debug("Uploaded device token")
        }
        task.resume()
    }
}
