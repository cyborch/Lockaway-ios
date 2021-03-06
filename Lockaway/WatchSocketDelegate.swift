//
//  WatchSocketDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 9/1/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import Starscream
import XCGLogger
import LockMessage
import Gloss
import WatchConnectivity

class WatchSocketDelegate: NSObject, WebSocketDelegate {
    
    var session: WCSession?
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocket) {
        log.debug("websocketDidConnect")
        sendStateRequest(socket: socket)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        log.debug("websocketDidDisconnect")
        reconnect(socket: socket)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        log.debug("websocketDidReceiveData")
        
        if let message = Message.from(data: data) as? LockedStateMessage {
            log.debug("Relaying data message to watch: \(String(data: data, encoding: .ascii) ?? "nil")")
            session?.sendMessage(message.toJSON()!, replyHandler: nil, errorHandler: { error in
                log.error("Error relaying message to watch: \(error)")
            })
            return
        }
        
        if let hello = Message.from(data: data) as? HelloMessage {
            log.info("Got hello from a desktop")
            if hello.role == .desktop {
                sendStateRequest(socket: socket)
            }
            return
        }
        
        log.warning("Unhandled data: \(String(data: data, encoding: .ascii) ?? "nil")")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        log.debug("websocketDidReceiveMessage")
    }
    
    // MARK: - Handlers
    
    func sendStateRequest(socket: WebSocket) {
        let message = QueryMessage(query: .isLocked)
        guard let data = message.toData() else {
            log.error("Could not serialize query message")
            return
        }
        log.debug("writing data: \(message.toJSON()!)")
        socket.write(data: data)
    }
    
    func reconnect(socket: WebSocket) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6)) {
            // If a previous connection attempt suceeded then stop here
            if !socket.isConnected {
                socket.connect()
                // This attempt might timeout in 5 seconds, so automatically retry in 6
                self.reconnect(socket: socket)
            }
        }
    }
}
