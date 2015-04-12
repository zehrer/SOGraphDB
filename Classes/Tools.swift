//
//  Tools.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 28.08.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

class SOTypedCache<O :AnyObject> {
    
    let cache = NSCache()
    
    func setObject(obj: O, forKey key : Int) {
        cache.setObject(obj, forKey: key)
    }
    
    func objectForKey(key: Int) -> O? {
        return cache.objectForKey(key) as! O?
    }
    
    func removeObjectForKey(key: Int) {
        cache.removeObjectForKey(key)
    }
    
    var name : String {
        set(newValue) {
            cache.name = newValue
        }
        
        get {
            return cache.name
        }
    }
    
    var countLimit: Int {
        set(newValue) {
            cache.countLimit = newValue
        }
        
        get {
            return cache.countLimit
        }
    }
    
    var delegate: NSCacheDelegate? {
        set(newValue) {
            cache.delegate = newValue
        }
        
        get {
            return cache.delegate
        }
    }
}