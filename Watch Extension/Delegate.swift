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
        guard let message = Message.from(data: messageData) else { return }
        handler(message: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let message = Message.from(json: message) else { return }
        handler(message: message)
    }

    func handler(message: Message) {
        if message is LockedStateMessage {
            let image = (message as! LockedStateMessage).state == .locked ? "Locked" : "Unlocked"
            locked?.setImage(UIImage(named: image))
            return
        }
        if message is OfflineMessage {
            locked?.setImage(UIImage(named: "Locked"))
            return
        }
    }
}
