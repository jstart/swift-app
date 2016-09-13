//
//  SwipeState.swift
//  Mesh
//
//  Created by Christopher Truman on 8/8/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct SwipeState {
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
    var gesture : UIPanGestureRecognizer?
    
    var config = SwipeConfig()
    
    mutating func start(_ gesture : UIPanGestureRecognizer) {
        self.gesture = gesture
        let touchPoint = gesture.location(in: gesture.view?.superview)
        startX = touchPoint.x
        startY = touchPoint.y
    }

    mutating func drag(_ gesture : UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: gesture.view?.superview)

        // X //
        changeX = CGFloat(touchPoint.x - startX)
        horizontalProgress = min(1, abs(changeX / config.xDistanceMinimumForDrag))

        // Y //
        changeY = CGFloat(touchPoint.y - startY)
        verticalProgress = min(1, abs(changeY / config.yDistanceMinimumForDrag))

        // Angle //
        direction = getSwipeDirection();
        
        // Velocity //
        velocityX = gesture.velocity(in: gesture.view?.superview).x
        velocityY = gesture.velocity(in: gesture.view?.superview).y
    }

    mutating func stop(_ gesture : UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: gesture.view?.superview)
        
        // X //
        endX = touchPoint.x
        changeX = touchPoint.x - startX
        
        // Y //
        endY = touchPoint.y
        changeY = touchPoint.y - startY
        
        // Velocity //
        velocityX = gesture.velocity(in: gesture.view?.superview).x
        velocityY = gesture.velocity(in: gesture.view?.superview).y
        
        // Angle //
        angle = atan2(velocityY, velocityX) * ((CGFloat) (180.0 / M_PI))
        if (angle < 0) { angle += 360.0 }
    }

    mutating func getSwipeDirection() -> UISwipeGestureRecognizerDirection {
        angle = atan2(velocityY, velocityX) * ((CGFloat) (180.0 / M_PI))
        if (angle < 0) { angle += 360.0 }

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
        
        return UISwipeGestureRecognizerDirection()
    }

    func isWithinAngle(_ boundaryStart : CGFloat, boundaryEnd : CGFloat, and : Bool) -> Bool {
        if (and) {
            return angle >= boundaryStart && angle <= boundaryEnd
        }
        else {
            return angle >= boundaryStart || angle <= boundaryEnd
        }
    }
    
    mutating func meetsPositionRequirements(_ swipeDirection : UISwipeGestureRecognizerDirection) -> (Bool) {
        if (!draggingInCurrentDirectionAllowed()) {
            return false
        }
        switch (swipeDirection as UISwipeGestureRecognizerDirection) {
        case UISwipeGestureRecognizerDirection.left:
            return self.gesture!.view!.center.x < (self.gesture!.view!.superview!.center.x - config.xDistanceMinimumForDrag)
        case UISwipeGestureRecognizerDirection.right:
            return self.gesture!.view!.center.x > (self.gesture!.view!.superview!.center.x + config.xDistanceMinimumForDrag)
        case UISwipeGestureRecognizerDirection.up:
            return true
        case UISwipeGestureRecognizerDirection.down:
            return true
        default:
            return false;
        }
    }
    
    mutating func meetsDragRequirements(_ swipeDirection : UISwipeGestureRecognizerDirection) -> (Bool) {
        if (!draggingInCurrentDirectionAllowed()) {
            return false
        }
        switch (swipeDirection as UISwipeGestureRecognizerDirection) {
            case UISwipeGestureRecognizerDirection.left:
                return horizontalProgress == 1 && changeX < 0
            case UISwipeGestureRecognizerDirection.right:
                return horizontalProgress == 1 && changeX > 0
            case UISwipeGestureRecognizerDirection.up:
                return verticalProgress == 1 && changeY > 0
            case UISwipeGestureRecognizerDirection.down:
                return verticalProgress == 1 && changeY < 0
        default:
            return false;
        }
    }
    
    mutating func meetsFlingRequirements(_ swipeDirection : UISwipeGestureRecognizerDirection) -> Bool {
        if (!draggingInCurrentDirectionAllowed()) {
            return false
        }
        switch (swipeDirection) {
        case UISwipeGestureRecognizerDirection.left:
            fallthrough
        case UISwipeGestureRecognizerDirection.right:
            return abs(velocityX) >= config.velocitySlopX && horizontalProgress >= config.xDistanceMinimumForFling;
        case UISwipeGestureRecognizerDirection.up:
            fallthrough
        case UISwipeGestureRecognizerDirection.down:
            return abs(velocityY) >= config.velocitySlopY && verticalProgress >= config.yDistanceMinimumForFling;
        default:
            return false;
        }
    }
    
    mutating func draggingInCurrentDirectionAllowed() -> Bool {
        switch (getSwipeDirection()) {
        case UISwipeGestureRecognizerDirection.left:
            return config.swipeLeftEnabled;
        case UISwipeGestureRecognizerDirection.right:
            return config.swipeRightEnabled;
        case UISwipeGestureRecognizerDirection.up:
            return config.swipeUpEnabled;
        case UISwipeGestureRecognizerDirection.down:
            return config.swipeDownEnabled;
        default:
            return false;
        }
    }
}
