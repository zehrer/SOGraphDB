//
//  CacheObjectStore.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 25.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//

import Foundation


class CacheObjectStore<O:ObjectCoding ,H:Coding>: ManagedObjectStore<O,H>  {

    let cache = NSCache();
    
    
    override func createObject() -> O {
        
        let result = super.createObject()
        
        let uid: NSNumber = result.uid!
        
        self.cache.setObject(result, forKey: uid)
        
        return result
    }
    
    
    
}
