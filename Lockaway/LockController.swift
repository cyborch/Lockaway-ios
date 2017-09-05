//
//  LockController.swift
//  Lockaway
//
//  Created by Anders Borch on 8/31/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import UIKit
import LockMessage
import SVProgressHUD
import CoreMotion
import UserNotifications

let WalkawayKey = "WalkAway"

class LockController: UIViewController {
    var isLoading = false
    
    @IBOutlet var service: Service?
    var auto: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.bool(forKey: WalkawayKey)
        }
        set(auto) {
            let ud = UserDefaults.standard
            ud.set(auto, forKey: WalkawayKey)
            ud.synchronize()
        }
    }
    
    let pedometer = CMPedometer()
    var queryTime = Date()
    var stepCount = 0

    let notificationDelegate = NotificationDelegate()

    @IBOutlet var lock: UIImageView?
    @IBOutlet var message: UILabel?
    @IBOutlet var walk: UILabel? {
        didSet {
            if auto && CMPedometer.isStepCountingAvailable() {
                walk?.text = "auto locking when you walk away"
            } else {
                walk?.text = "manual locking"
            }
        }
    }
    @IBOutlet var toggle: UIButton? {
        didSet {
            if !CMPedometer.isStepCountingAvailable() {
                toggle?.isEnabled = false
                toggle?.tintColor = .gray
            } else {
                if auto {
                    toggle?.isSelected = true
                } else {
                    toggle?.isSelected = false
                }
            }
        }
    }
    
    func showLoading() {
        isLoading = true
        guard isViewLoaded else { return }
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.show()
        lock?.image = nil
        message?.text = "Getting locked state for your Mac"
    }
    
    override func viewDidLoad() {
        if isLoading {
            showLoading()
        }
        if auto {
            startUpdates()
        }
    }
    
    func update(message: LockedStateMessage) {
        SVProgressHUD.dismiss()
        isLoading = false
        switch message.state {
        case .locked:
            lock?.image = UIImage(named: "Locked")
            self.message?.text = "Your Mac is current locked"
        case .unlocked:
            lock?.image = UIImage(named: "Unlocked")
            self.message?.text = "Your Mac is current NOT locked"
            if auto {
                queryStepCount()
            }
        }
    }
    
    @IBAction func close() {
        let alert = UIAlertController(title: "Pair Again?",
                                      message: "This will set your device to pairing mode until it is paired with the Magic Lock desktop app",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Pair",
                                      style: .destructive,
                                      handler: { action in
                                        SVProgressHUD.dismiss()
                                        self.isLoading = false
                                        let ud = UserDefaults.standard
                                        ud.removeObject(forKey: DiscoveredKey)
                                        ud.synchronize()
                                        self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { action in
                                        alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func registerNotifications() {
        let ud = UserDefaults.standard
        guard ud.bool(forKey: WalkawayKey) else { return }
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            guard error == nil else { log.error("Error Requesting notifications: \(error!)") ; return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func queryStepCount() {
        pedometer.queryPedometerData(from: queryTime, to: Date(), withHandler: { (data, error) in
            guard error == nil else { log.error("Error getting step count: \(error!)") ; return }
            guard let stepCount = data?.numberOfSteps.intValue else { return }
            if stepCount > self.stepCount {
                self.service?.sendLockMessage()
            }
            self.stepCount = stepCount
            self.queryTime = Date()
        })
    }

    func startUpdates() {
        registerNotifications()
        queryStepCount()
    }
    
    @IBAction func toggleWalkaway(_ button: UIButton) {
        button.isSelected = !button.isSelected
        auto = button.isSelected
        if button.isSelected {
            walk?.text = "auto locking when you walk away"
            startUpdates()
        } else {
            walk?.text = "manual locking"
            //manager.stopMagnetometerUpdates()
        }
    }
    
}
