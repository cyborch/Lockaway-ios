//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Anders Borch on 9/1/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import LockMessage
import Gloss
import CoreMotion

class InterfaceController: WKInterfaceController {

    @IBOutlet var locked: WKInterfaceImage? {
        didSet {
            delegate.locked = locked
        }
    }
    
    private let delegate = Delegate()
    
    private var session: WCSession {
        let session = WCSession.default()
        session.delegate = self.delegate
        return session
    }

    let manager = CMMotionActivityManager()
    
    func sendLockMessage() {
        let message = LockMessage()
        session.sendMessage(message.toJSON()!, replyHandler: nil, errorHandler: nil)
    }
    
    func startUpdates() {
        manager.startActivityUpdates(to: .main,
                                     withHandler: { activity in
                                        if activity?.walking ?? false || activity?.running ?? false {
                                            self.sendLockMessage()
                                        }
        })
    }
    
    func handler(reply: JSON) {
        if let message = Message.from(json: reply) as? LockedStateMessage {
            let image = message.state == .locked ? "Locked" : "Unlocked"
            locked?.setImage(UIImage(named: image))
            return
        }
    }

    @IBAction func lock() {
        let message = LockMessage()
        session.sendMessage(message.toJSON()!, replyHandler: nil, errorHandler: { error in
            print("Error sending message from watch: \(error)")
        })
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        session.activate()
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}