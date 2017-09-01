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

fileprivate let WalkawayKey = "WalkAway"

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
    
    let manager = CMMotionActivityManager()
    
    @IBOutlet var lock: UIImageView?
    @IBOutlet var message: UILabel?
    @IBOutlet var walk: UILabel? {
        didSet {
            if auto {
                walk?.text = "auto locking when you walk away"
            } else {
                walk?.text = "manual locking"
            }
        }
    }
    @IBOutlet var toggle: UIButton? {
        didSet {
            if auto {
                toggle?.isSelected = true
            } else {
                toggle?.isSelected = false
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
    
    func startUpdates() {
        manager.startActivityUpdates(to: .main,
                                     withHandler: { activity in
                                        if activity?.walking ?? false || activity?.running ?? false {
                                            log.info("Walking detected - sending lock message")
                                            self.service?.sendLockMessage()
                                        }
        })
    }
    
    @IBAction func toggleWalkaway(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            walk?.text = "auto locking when you walk away"
            startUpdates()
        } else {
            walk?.text = "manual locking"
            manager.stopActivityUpdates()
        }
        auto = button.isSelected
    }
    
}
