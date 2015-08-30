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
    
    
    func outRelationshipByKey(keyNode:Node) -> Relationship?
    //func inRelationshipByKey(keyNode:Node) -> Relationship?
    
    //func containsRelationship(keyNode:Node) -> Bool
    
}

extension RelationshipAccess {
    
    // Generic read methode
    // The handler is called by all properties of the chain
    // Return: true if the while loop can be stopped
    func readOutRelationship(handler : (relationship : Relationship) -> Bool) {
        
        var relationship:Relationship? = nil
        var nextOutRelationshipID = self.nextOutRelationshipID
        
        while (nextOutRelationshipID > 0) {
            
            relationship = context.readRelationship(nextOutRelationshipID)
            
            if (relationship != nil) {
                
                let stop = handler(relationship: relationship!)
                
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
    
}