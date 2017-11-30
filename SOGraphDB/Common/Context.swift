//
//  Context.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 30.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public protocol Context {
    
    weak var context : SOGrapheDB! { get set }
    
    var dirty: Bool {get set}
}
