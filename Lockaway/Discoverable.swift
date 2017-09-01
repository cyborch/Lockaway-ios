//
//  Discoverable.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import CoreBluetooth

fileprivate let service = CBUUID(string: "EFC325B2-2281-4BB4-9196-8A8904980ABF")
fileprivate let characteristic = CBUUID(string: "0E486070-4BDB-4902-9F78-C037F80B8577")

class Discoverable: NSObject, CBPeripheralManagerDelegate {

    private var shouldAdvertise = false
    private var isAdvertising = false
    
    @IBOutlet var controller: IntroController?
    
    func startAdvertise(manager: CBPeripheralManager) {
        shouldAdvertise = true
        if manager.state == .poweredOn && !isAdvertising {
            let primary = CBMutableService(type: service, primary: true)
            let char = CBMutableCharacteristic(type: characteristic,
                                               properties: CBCharacteristicProperties.read,
                                               value: nil,
                                               permissions: CBAttributePermissions.readable)
            primary.characteristics = [char]
            manager.add(primary)
            print("starting advertising")
            manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service]])
        }
    }
    
    func stopAdvertise(manager: CBPeripheralManager) {
        guard isAdvertising else { return }
        isAdvertising = false
        print("stopping advertising")
        manager.stopAdvertising()
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn && shouldAdvertise && !isAdvertising {
            let primary = CBMutableService(type: service, primary: true)
            let char = CBMutableCharacteristic(type: characteristic,
                                               properties: CBCharacteristicProperties.read,
                                               value: nil,
                                               permissions: CBAttributePermissions.readable)
            primary.characteristics = [char]
            peripheral.add(primary)
            print("starting advertising")
            peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service]])
            isAdvertising = true
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("didReceiveRead")
        request.value = SocketID.data
        peripheral.respond(to: request, withResult: .success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.controller?.performSegue(withIdentifier: "Paired", sender: nil)
        }
    }
}
