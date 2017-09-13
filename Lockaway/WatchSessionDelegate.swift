//
//  WatchSessionDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 9/1/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation

import WatchConnectivity
import LockMessage
import Gloss

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    
    let socketDelegate = WatchSocketDelegate()
    
    lazy var service: Service = {
        let service = Service()
        service.delegate = self.socketDelegate
        return service
    }()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.debug("Activation completed with: \(activationState.rawValue)")
        if error != nil { log.error("Error activating watch session: \(error!)") }
        if activationState == .activated {
            socketDelegate.session = session
        } else {
            socketDelegate.session = nil
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        log.debug("sessionDidBecomeInactive")
        socketDelegate.session = nil
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        log.debug("sessionDidDeactivate")
        socketDelegate.session = nil
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        log.debug("Relaying data message from watch: \(String(data: messageData, encoding: .ascii) ?? "nil")")
        service.socket.write(data: messageData)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        log.debug("Relaying dictionary message from watch: \(message)")
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: JSONSerialization.WritingOptions())
            service.socket.write(data: data)
        } catch let error {
            log.error("Error serializing message: \(error)")
        }
    }
}
