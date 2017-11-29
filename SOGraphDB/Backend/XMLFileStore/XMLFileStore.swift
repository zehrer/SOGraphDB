//
//  XMLFileStore.swift
//  SOGraphDB-Mac
//
//  Created by Stephan Zehrer on 29.11.17.
//  Copyright © 2017 Stephan Zehrer. All rights reserved.
//

import Foundation

public class XMLFileStore : SOGraphDBStore {
    
    open let xmlFileURL : URL
    
    //#pragma mark -
    
    public init(url: URL) throws {
        self.xmlFileURL = url
        //readXMLFile()
    }

    public func readXMLFile() throws {
        
        //var error : NSError?
        
        // TODO: ERROR Handling
        let xmlFileWrapper: FileWrapper? = try! FileWrapper(url: xmlFileURL, options:FileWrapper.ReadingOptions.immediate)
        
        if xmlFileWrapper != nil {
          // TODO READ DATA
        }
        
    }
    
}
