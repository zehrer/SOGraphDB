//
//  RelationshipAccess.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 30.08.15.
//  Copyright © 2015 Stephan Zehrer. All rights reserved.
//

import Foundation

public protocol RelationshipAccess : Identiy, Context, CRUD {
    
    var nextOutRelationshipID: UID {get set}  // internal link to the relationship
    var nextInRelationshipID: UID {get set}  // internal link to the relationship
    
    
    func outRelationshipByKey(_ keyNode:Node) -> Relationship?
    //func inRelationshipByKey(keyNode:Node) -> Relationship?
    
    //func containsRelationship(keyNode:Node) -> Bool
    
    func addOutRelationshipNode(_ endNode: Node) -> Relationship?
    
}

extension RelationshipAccess {
    
    // Generic read methode
    // The handler is called by all relationship of the chain
    // Return: true if the while loop can be stopped
    func readOutRelationship(_ handler : (_ relationship : Relationship) -> Bool) {
        
        var relationship:Relationship? = nil
        var nextOutRelationshipID = self.nextOutRelationshipID
        
        while (nextOutRelationshipID > 0) {
            
            relationship = context.readRelationship(nextOutRelationshipID)
            
            if (relationship != nil) {
                
                let stop = handler(relationship!)
                
                if stop {
                    break
                }
                
                nextOutRelationshipID = relationship!.nextOutRelationshipID
            } else {
                // ERROR: nextOutRelationshipID is not zero but readProperty read nil
                assertionFailure("ERROR: Database inconsistent")
            }
        }
    }
    
    public func outRelationshipByKey(_ keyNode:Node) -> Relationship? {
        let result : Relationship? = nil
        
        readOutRelationship({ relationship in
            
            /**
            if relationship.keyNodeID == keyNode.uid {
                result = property
                return true
            }
*/
            
            return false
            
        })
        
        return result
        
    }
    
    public func addOutRelationshipNode(_ endNode: Node) -> Relationship? {
        return nil
    }
    
    
}
