//
//  ObjC.h
//  Ripple
//
//  Created by Christopher Truman on 10/27/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)())tryBlock error:(__autoreleasing NSError **)error;

@end
