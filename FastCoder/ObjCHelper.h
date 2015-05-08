//
//  ObjCHelper.h
//  FastCoder
//
//  Created by Stephan Zehrer on 26.04.15.
//
//

#import <Foundation/Foundation.h>

@interface ObjCHelper : NSObject

+ (NSObject *)initClass:(NSString *)name withCoder:(NSCoder *)aDecoder;

@end
