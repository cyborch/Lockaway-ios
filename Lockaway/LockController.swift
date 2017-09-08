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
import UserNotifications

class LockController: UIViewController {
    var isLoading = false
    
    @IBOutlet var service: Service?
    
    @IBOutlet var lock: UIImageView?
    @IBOutlet var message: UILabel?
    
    private let notificationDelegate = NotificationDelegate()
    
    func showLoading() {
        isLoading = true
        guard isViewLoaded else { return }
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        lock?.image = nil
        message?.text = "Getting locked state for your Mac"
    }
    
    override func viewDidLoad() {
        SVProgressHUD.setBackgroundColor(.clear)
        if isLoading {
            showLoading()
        }
    }
    
    func update(message: Message) {
        SVProgressHUD.dismiss()
        isLoading = false

        if let locked = message as? LockedStateMessage {
            switch locked.state {
            case .locked:
                lock?.image = UIImage(named: "Locked")
                self.message?.text = "Your Mac is currently locked"
            case .unlocked:
                lock?.image = UIImage(named: "Unlocked")
                self.message?.text = "Your Mac is currently NOT locked"
            }
        }
        
        if message is OfflineMessage {
            lock?.image = UIImage(named: "Locked")
            self.message?.text = "Your Mac is currently offline\n(which probably means it's locked)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) { 
            self.registerNotifications()
        }
    }
    
    func registerNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        center.requestAuthorization(options: [.alert]) { (granted, error) in
            guard error == nil else { log.error("Error Requesting notifications: \(error!)") ; return }
            UIApplication.shared.registerForRemoteNotifications()
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

}
