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

class LockController: UIViewController {
    var isLoading = false
    
    @IBOutlet var lock: UIImageView?
    @IBOutlet var message: UILabel?

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
    
    
}
