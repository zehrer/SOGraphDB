//
//  Context.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 30.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public protocol GraphStore {
    
    var graphStore : SOGraphDBStore! { get set }
    
    var dirty: Bool {get set}
}
