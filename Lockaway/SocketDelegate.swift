//
//  SocketDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 8/31/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import Starscream
import XCGLogger
import LockMessage
import Gloss
import UserNotifications

class SocketDelegate: NSObject, WebSocketDelegate {
    
    @IBOutlet var controller: LockController?
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocket) {
        log.debug("websocketDidConnect")
        sendStateRequest(socket: socket)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        log.debug("websocketDidDisconnect")
        controller?.showLoading()
        reconnect(socket: socket)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        log.debug("websocketDidReceiveData")
        
        if let message = Message.from(data: data) as? LockedStateMessage {
            controller?.update(message: message)
            return
        }
        
        if let message = Message.from(data: data) as? ResponseMessage {
            log.debug("Got response message")
            notify(response: message)
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
    
    func notify(response: ResponseMessage) {
        guard let original = Message.from(json: response.respondingTo) as? LockMessage else { return }
        if original.source == .motion {
            // Create Notification Content
            let notificationContent = UNMutableNotificationContent()
            
            // Configure Notification Content
            notificationContent.title = "Locked"
            
            //notificationContent.subtitle = ""
            notificationContent.body = "Your mac was automatically locked when you walked away."

            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            
            let notificationRequest = UNNotificationRequest(identifier: "LockNotification", content: notificationContent, trigger: notificationTrigger)
            
            // Add Request to User Notification Center
            UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                if let error = error {
                    log.error("Unable to add notification request (\(error), \(error.localizedDescription))")
                }
            }
        }
    }
    
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
