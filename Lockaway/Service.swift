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
}
