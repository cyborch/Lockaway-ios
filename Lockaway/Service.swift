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

class Service: NSObject {
    
    @IBOutlet var controller: LockController? {
        didSet {
            controller?.showLoading()
        }
    }
    
    let socket: WebSocket = {
        log.debug("Creating socket /pipe/\(SocketID.string)")
        let socket = WebSocket(url: URL(string: "wss://jsonpipe.cyborch.com/pipe/\(SocketID.string)")!)
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
    
    @IBAction func sendLockMessage() {
        let message = LockMessage()
        guard let data = message.toData() else {
            log.error("Could not serialize lock message")
            return
        }
        socket.write(data: data)
    }
}
