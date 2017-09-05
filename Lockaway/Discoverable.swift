//
//  Discoverable.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import UIKit
import CoreBluetooth

fileprivate let service = CBUUID(string: "EFC325B2-2281-4BB4-9196-8A8904980ABF")
fileprivate let socketCharacteristic = CBUUID(string: "0E486070-4BDB-4902-9F78-C037F80B8577")
fileprivate let nameCharacteristic = CBUUID(string: "F021A685-9BC6-491B-A3DC-0816F0026F57")

class Discoverable: NSObject, CBPeripheralManagerDelegate {

    private var shouldAdvertise = false
    private var isAdvertising = false
    
    @IBOutlet var controller: IntroController?
    
    internal func addCharacteristics(manager: CBPeripheralManager) {
        let primary = CBMutableService(type: service, primary: true)
        let sock = CBMutableCharacteristic(type: socketCharacteristic,
                                           properties: CBCharacteristicProperties.read,
                                           value: nil,
                                           permissions: CBAttributePermissions.readable)
        let name = CBMutableCharacteristic(type: nameCharacteristic,
                                           properties: CBCharacteristicProperties.read,
                                           value: UIDevice.current.name.data(using: .utf8),
                                           permissions: CBAttributePermissions.readable)
        primary.characteristics = [sock, name]
        manager.add(primary)
    }
    
    func startAdvertise(manager: CBPeripheralManager) {
        shouldAdvertise = true
        if manager.state == .poweredOn && !isAdvertising {
            addCharacteristics(manager: manager)
            log.debug("starting advertising")
            manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service]])
        }
    }
    
    func stopAdvertise(manager: CBPeripheralManager) {
        guard isAdvertising else { return }
        isAdvertising = false
        log.debug("stopping advertising")
        manager.stopAdvertising()
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn && shouldAdvertise && !isAdvertising {
            addCharacteristics(manager: peripheral)
            log.debug("starting advertising")
            peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service]])
            isAdvertising = true
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        log.debug("didReceiveRead")
        request.value = SocketID.data
        peripheral.respond(to: request, withResult: .success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.controller?.performSegue(withIdentifier: "Paired", sender: nil)
        }
    }
}
