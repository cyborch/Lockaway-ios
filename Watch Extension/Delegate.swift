//
//  Delegate.swift
//  Lockaway
//
//  Created by Anders Borch on 9/1/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import WatchConnectivity
import LockMessage
import Gloss

class Delegate: NSObject, WCSessionDelegate {
    
    var locked: WKInterfaceImage?
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard error == nil else { print("Error activating watch session: \(error!)") ; return }
        session.sendMessage(HelloMessage(role: .watch).toJSON()!, replyHandler: nil, errorHandler: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        #if DEBUG
            print("Got data message from app: \(String(data: messageData, encoding: .ascii) ?? "nil")")
        #endif
        if let message = Message.from(data: messageData) as? LockedStateMessage {
            let image = message.state == .locked ? "Locked" : "Unlocked"
            locked?.setImage(UIImage(named: image))
            return
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        #if DEBUG
            print("Got dictionary message from app: \(message)")
        #endif
        if let message = Message.from(json: message) as? LockedStateMessage {
            let image = message.state == .locked ? "Locked" : "Unlocked"
            locked?.setImage(UIImage(named: image))
            return
        }
    }
}
