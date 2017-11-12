//
//  Tools.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 28.08.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation

class SOTypedCache<O :AnyObject> {
    
    let cache = NSCache<AnyObject, AnyObject>()
    
    func setObject(_ obj: O, forKey key : Int) {
        cache.setObject(obj, forKey: key as AnyObject)
    }
    
    func objectForKey(_ key: Int) -> O? {
        return cache.object(forKey: key as AnyObject) as! O?
    }
    
    func removeObjectForKey(_ key: Int) {
        cache.removeObject(forKey: key as AnyObject)
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
