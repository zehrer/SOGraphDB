//
//  NSURL.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 08.05.15.
//  Copyright (c) 2015 Stephan Zehrer. All rights reserved.
//

import Foundation


public extension NSURL {
   
    public func isFileExisting() -> Bool {
        let path = self.path
        
        if path != nil {
            return NSFileManager.defaultManager().fileExistsAtPath(path!)
        } else {
          return false
        }
    }
    
    public func deleteFile() {
        if self.isFileExisting() {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(self)
            } catch {
                NSLog("ERROR: during delete of file: \(path)")
            }
        }
    }
}

/**
- (BOOL)isFileExisting;
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self path]];
}

- (void)deleteFile;
{
    if ([self isFileExisting]) {
        NSError *aError = nil;
        
        [[NSFileManager defaultManager] removeItemAtURL:self error:&aError];
        
        if (aError) {
            NSLog(@"ERROR: delete %@",[self path]);
        }
    }
}


*/