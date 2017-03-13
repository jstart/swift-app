//
//  ObjC.m
//  Ripple
//
//  Created by Christopher Truman on 10/27/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjC.h"

@implementation ObjC

+ (BOOL)catchException:(void(^)())tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
    }
}

@end
