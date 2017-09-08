//
//  ViewController.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import UIKit
import CoreBluetooth

fileprivate let PromotionUrl = "https://magicmaclock.cyborch.com/macosapp"
let DiscoveredKey = "IsDiscovered"

class IntroController: UIViewController {

    @IBOutlet var introText: UILabel? {
        didSet {
            introText?.text = "To lock your Mac directly from your \(UIDevice.current.model) or Apple Watch, " +
                "launch the Lockaway desktop app to start pairing your devices."
        }
    }

    @IBOutlet var discoverable: Discoverable?
    
    lazy var manager: CBPeripheralManager = {
        let manager = CBPeripheralManager(delegate: self.discoverable, queue: nil)
        return manager
    }()

    override func viewDidAppear(_ animated: Bool) {
        // Move on to next screen immediately, if already paired
        let ud = UserDefaults.standard
        if ud.bool(forKey: DiscoveredKey) {
            self.performSegue(withIdentifier: "Paired", sender: nil)
        } else {
            discoverable?.startAdvertise(manager: manager)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        discoverable?.stopAdvertise(manager: manager)
    }
    
    @IBAction func getDesktopApp(_ sender: Any) {
        UIApplication.shared.open(URL(string: PromotionUrl)!,
                                  options: [:],
                                  completionHandler: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: DiscoveredKey)
        ud.synchronize()
    }
}
