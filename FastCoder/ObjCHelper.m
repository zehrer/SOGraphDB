//
//  ObjCHelper.m
//  FastCoder
//
//  Created by Stephan Zehrer on 26.04.15.
//
//

#import "ObjCHelper.h"

@implementation ObjCHelper

+ (NSObject *)initClass:(NSString *)className withCoder:(NSCoder *)decoder {
    
    return [[NSClassFromString(className) alloc] initWithCoder:decoder];
}

@end
