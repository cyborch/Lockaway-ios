//
//  AppDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import UIKit
import XCGLogger

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .none)
        return true
    }
}

