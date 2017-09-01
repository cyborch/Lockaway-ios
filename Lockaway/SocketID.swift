//
//  SocketID.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation

fileprivate let key = "SocketID"

class SocketID {
    
    static var string: String {
        get {
            let ud = UserDefaults.standard
            let random = SocketID.randomString(length: 19)
            log.info {
                if ud.string(forKey: key) != nil {
                    return "Resuming /pipe/\(ud.string(forKey: key)!)"
                } else {
                    return "Generating /pipe/\(random)"
                }
            }
            let id = ud.string(forKey: key) ?? random
            ud.set(id, forKey: key)
            ud.synchronize()
            return id
        }
    }

    static var data: Data {
        get {
            return SocketID.string.data(using: String.Encoding.ascii)!
        }
    }
    
    private static func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }

}
