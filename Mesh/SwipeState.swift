//
//  SwipeState.swift
//  Mesh
//
//  Created by Christopher Truman on 8/8/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class SwipeState {
    var angle : CGFloat = 0.0,              // the angle in degrees of the current swipe
    startX : CGFloat = 0.0,                 // the x pointer coord at the start of a swipe
    endX : CGFloat = 0.0,                   // the x pointer coord at the end of a swipe
    startY : CGFloat = 0.0,                 // the y pointer coord at the start of a swipe
    endY : CGFloat = 0.0,                   // the y pointer coord at teh end of a swipe
    changeX : CGFloat = 0.0,                // the current distance swiped on the x axis.
    changeY : CGFloat = 0.0,                // the current distance swiped on the y axis.
    velocityX : CGFloat = 0.0,              // the current velocity of the gesture on the X axis.
    velocityY : CGFloat = 0.0,              // the current velocity of the gesture on the Y axis.
    horizontalProgress : CGFloat = 0.0,    // the progress of the current swipe from 0 to 1 on X. 1 is a valid swipe.
    verticalProgress : CGFloat = 0.0    // the progress of the current swipe from 0 to 1 on Y. 1 is a valid swipe.

    var direction : UISwipeGestureRecognizerDirection? = nil
    
    var config = SwipeConfig()
    
    func start(_ gesture : UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: gesture.view)
        startX = touchPoint.x
        startY = touchPoint.y
    }

    func drag(_ gesture : UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: gesture.view)

        // X //
        changeX = CGFloat(touchPoint.x - startX)
        horizontalProgress = min(1, abs(changeX / config.xDistanceMinimumForFling))
        
        // Y //
        changeY = CGFloat(touchPoint.y - startY)
        verticalProgress = min(1, abs(changeY / config.yDistanceMinimumForFling))
        
        // Angle //
        direction = getSwipeDirection();
    }

    func stop(_ gesture : UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: gesture.view)
        
        // X //
        endX = touchPoint.x
        changeX = touchPoint.x - startX
        
        // Y //
        endY = touchPoint.y
        changeY = touchPoint.y - startY
        
        // Angle //
        angle = (atan2(changeY, -changeX) * ((CGFloat) (180.0 / M_PI)))
        angle = angle < 0 ? angle + SwipeConfig.DEGREES_360 : angle
    }

    func getSwipeDirection() -> UISwipeGestureRecognizerDirection {
        if (isWithinAngle(config.swipeLeftBoundaryStart, boundaryEnd: config.swipeLeftBoundaryEnd, and: true)) {
            return .left
        }
        else if (isWithinAngle(config.swipeRightBoundaryStart, boundaryEnd: config.swipeRightBoundaryEnd, and: false)) {
            return .right
        }
        else if (isWithinAngle(config.swipeUpBoundaryStart, boundaryEnd: config.swipeUpBoundaryEnd, and: true)) {
            return .up
        }
        else if (isWithinAngle(config.swipeDownBoundaryStart, boundaryEnd: config.swipeDownBoundaryEnd, and: true)) {
            return .down
        }
        
        return .up
    }

    func isWithinAngle(_ boundaryStart : CGFloat, boundaryEnd : CGFloat, and : Bool) -> Bool {
        if (and) {
            return angle >= boundaryStart && angle <= boundaryEnd
        }
        else {
            return angle >= boundaryStart || angle <= boundaryEnd
        }
    }
    
    func meetsDragRequirements(swipeDirection : UISwipeGestureRecognizerDirection) -> (Bool) {
        switch (swipeDirection as UISwipeGestureRecognizerDirection) {
            case UISwipeGestureRecognizerDirection.left:
                fallthrough
            case UISwipeGestureRecognizerDirection.right:
                return horizontalProgress == 1 && startX - changeX > 0;
            case UISwipeGestureRecognizerDirection.up:
                fallthrough
            case UISwipeGestureRecognizerDirection.down:
                return verticalProgress == 1 && startY  - changeY > 0;
        default:
            return false;
        }
    }
}
