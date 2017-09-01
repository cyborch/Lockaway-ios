//
//  AppDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import UIKit
import XCGLogger
import WatchConnectivity
import UserNotifications

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let watchDelegate = WatchSessionDelegate()
    private let notificationDelegate = NotificationDelegate()
    
    private var session: WCSession {
        let session = WCSession.default()
        session.delegate = self.watchDelegate
        return session
    }
    
    var window: UIWindow?

    func register() {
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            guard error == nil else { log.error("Error Requesting notifications: \(error!)") ; return }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .none)
        register()
        session.activate()
        return true
    }
}

