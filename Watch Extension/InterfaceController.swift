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

class Delegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
}

class InterfaceController: WKInterfaceController {

    private let delegate = Delegate()
    
    private var session: WCSession {
        let session = WCSession.default()
        session.delegate = self.delegate
        return session
    }
    
    @IBAction func lock() {
        
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
