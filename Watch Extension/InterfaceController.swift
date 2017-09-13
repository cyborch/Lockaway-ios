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

class InterfaceController: WKInterfaceController {

    var timeout: Timer?
    
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

    func startActivity() {
        locked?.setImageNamed("Activity")
        locked?.startAnimatingWithImages(in: NSRange(location: 1, length: 30), duration: 1.0, repeatCount: 5)
        
        if timeout?.isValid ?? false {
            timeout?.fireDate = Date().addingTimeInterval(5)
        } else {
            timeout = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] timer in
                self?.locked?.setImage(UIImage(named: "Locked"))
            })
        }
    }
    
    func sendLockMessage(source: LockMessage.Source) {
        let message = LockMessage(source: source)
        session.sendMessage(message.toJSON()!, replyHandler: nil, errorHandler: nil)
    }
    
    func sendQueryMessage() {
        let message = QueryMessage(query: .isLocked)
        session.sendMessage(message.toJSON()!, replyHandler: nil, errorHandler: nil)
    }
    
    @IBAction func lock() {
        startActivity()
        sendLockMessage(source: .button)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        startActivity()
        if session.activationState == .activated {
            sendQueryMessage()
        } else {
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
