//
//  SwipeConfig.swift
//  Mesh
//
//  Created by Christopher Truman on 8/8/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SwipeConfig {
    
    static let DEFAULT_ANGLE_SWIPE_RIGHT : CGFloat = 70
    static let DEFAULT_ANGLE_SWIPE_LEFT : CGFloat = 70
    static let DEFAULT_ANGLE_SWIPE_UP : CGFloat = 80
    static let DEFAULT_ANGLE_SWIPE_DOWN : CGFloat = 15
    
    static let DEGREES_90 : CGFloat = 90
    static let DEGREES_180 : CGFloat = 180
    static let DEGREES_270 : CGFloat = 270
    static let DEGREES_360 : CGFloat = 360
    static let VELOCITY_UNITS_SECONDS = 1
    
    // Swipe direction switches
    var swipeLeftEnabled = true,
    swipeRightEnabled = true,
    swipeUpEnabled = false,
    swipeDownEnabled = false
    
    // Swipe angle boundaries
    var swipeRightBoundaryStart,
    swipeRightBoundaryEnd,
    swipeLeftBoundaryStart,
    swipeLeftBoundaryEnd,
    swipeUpBoundaryStart,
    swipeUpBoundaryEnd,
    swipeDownBoundaryStart,
    swipeDownBoundaryEnd : CGFloat
    
    // Swipe position and speed settings
    var velocitySlopX : CGFloat = 50,
    velocitySlopY : CGFloat = 50,
    xDistanceMinimumForDrag : CGFloat = 20,
    yDistanceMinimumForDrag : CGFloat = 20,
    xDistanceMinimumForFling : CGFloat = 0.5,
    yDistanceMinimumForFling : CGFloat = 0.2
    
    let angleSwipeRight = DEFAULT_ANGLE_SWIPE_RIGHT
    let angleSwipeLeft = DEFAULT_ANGLE_SWIPE_LEFT
    let angleSwipeUp = DEFAULT_ANGLE_SWIPE_UP
    let angleSwipeDown = DEFAULT_ANGLE_SWIPE_DOWN
    
    init() {
        swipeRightBoundaryStart = CGFloat(SwipeConfig.DEGREES_360 - angleSwipeRight)
        swipeRightBoundaryEnd = CGFloat(angleSwipeRight)
        
        swipeLeftBoundaryStart = CGFloat(SwipeConfig.DEGREES_180 - angleSwipeRight)
        swipeLeftBoundaryEnd = CGFloat(SwipeConfig.DEGREES_180 + angleSwipeRight)
        
        swipeDownBoundaryStart = CGFloat(SwipeConfig.DEGREES_90 - angleSwipeDown)
        swipeDownBoundaryEnd = CGFloat(SwipeConfig.DEGREES_90 + angleSwipeDown)
        
        swipeUpBoundaryStart = CGFloat(SwipeConfig.DEGREES_270 - angleSwipeUp)
        swipeUpBoundaryEnd = CGFloat(SwipeConfig.DEGREES_270 + angleSwipeUp)
    }
    
}
