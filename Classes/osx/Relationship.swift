//
//  Relationship.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 10.06.14.
//  Copyright (c) 2014 Stephan Zehrer. All rights reserved.
//


struct RELATIONSHIP : Init {
    var relationshipTypeNodeID: UID = 0; // 4
    var nextPropertyID: UID  = 0;  // 4
    
    var startNodeID: UID = 0; // 4
    var startNodePrevRelationID: UID = 0; // 4
    var startNodeNextRelationID: UID = 0; // 4
    
    var endNodeID: UID = 0; // 4
    var endNodePrevRelationID: UID = 0; // 4
    var endNodeNextRelationID: UID = 0; // 4
    
    init() {
        
    }
}

class Relationship : GraphElement, Coding {
    
    var data: RELATIONSHIP = RELATIONSHIP()
    
     required init() {
        
    }
    
    //decoding NSData
    required init(data: RELATIONSHIP) {
        self.data = data
        
    }

}