//
//  LogoView.swift
//  Ripple
//
//  Created by Christopher Truman on 11/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

class LogoView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let combinedShape = UIBezierPath()
        combinedShape.move(to: CGPoint(x: 105.16, y: 84.64))
        combinedShape.addCurve(to: CGPoint(x: 99.66, y: 82.26), controlPoint1: CGPoint(x: 103.57, y: 84.64), controlPoint2: CGPoint(x: 101.07, y: 82.97))
        combinedShape.addCurve(to: CGPoint(x: 94.57, y: 79.3), controlPoint1: CGPoint(x: 97.9, y: 81.38), controlPoint2: CGPoint(x: 96.2, y: 80.39))
        combinedShape.addCurve(to: CGPoint(x: 86.26, y: 71.95), controlPoint1: CGPoint(x: 91.49, y: 77.23), controlPoint2: CGPoint(x: 88.68, y: 74.77))
        combinedShape.addCurve(to: CGPoint(x: 76.43, y: 50.7), controlPoint1: CGPoint(x: 81.22, y: 66.06), controlPoint2: CGPoint(x: 77.64, y: 58.36))
        combinedShape.addCurve(to: CGPoint(x: 75.31, y: 39.48), controlPoint1: CGPoint(x: 75.84, y: 46.99), controlPoint2: CGPoint(x: 75.67, y: 43.22))
        combinedShape.addCurve(to: CGPoint(x: 74.78, y: 35.16), controlPoint1: CGPoint(x: 75.18, y: 38.04), controlPoint2: CGPoint(x: 75.01, y: 36.6))
        combinedShape.addCurve(to: CGPoint(x: 48.73, y: 2.98), controlPoint1: CGPoint(x: 72.39, y: 20.2), controlPoint2: CGPoint(x: 62.64, y: 8.63))
        combinedShape.addCurve(to: CGPoint(x: 35.06, y: 0.25), controlPoint1: CGPoint(x: 44.49, y: 1.25), controlPoint2: CGPoint(x: 39.66, y: 0.43))
        combinedShape.addCurve(to: CGPoint(x: 11.31, y: 0.03), controlPoint1: CGPoint(x: 27.15, y: -0.06), controlPoint2: CGPoint(x: 19.23, y: -0.01))
        combinedShape.addCurve(to: CGPoint(x: 0, y: 0.04), controlPoint1: CGPoint(x: 7.51, y: 0.02), controlPoint2: CGPoint(x: 3.73, y: 0.04))
        combinedShape.addCurve(to: CGPoint(x: 5.5, y: 2.42), controlPoint1: CGPoint(x: 1.59, y: 0.04), controlPoint2: CGPoint(x: 4.09, y: 1.72))
        combinedShape.addCurve(to: CGPoint(x: 10.59, y: 5.38), controlPoint1: CGPoint(x: 7.25, y: 3.31), controlPoint2: CGPoint(x: 8.96, y: 4.29))
        combinedShape.addCurve(to: CGPoint(x: 18.9, y: 12.73), controlPoint1: CGPoint(x: 13.67, y: 7.45), controlPoint2: CGPoint(x: 16.48, y: 9.91))
        combinedShape.addCurve(to: CGPoint(x: 28.73, y: 33.98), controlPoint1: CGPoint(x: 23.94, y: 18.63), controlPoint2: CGPoint(x: 27.52, y: 26.32))
        combinedShape.addCurve(to: CGPoint(x: 29.85, y: 45.2), controlPoint1: CGPoint(x: 29.32, y: 37.7), controlPoint2: CGPoint(x: 29.49, y: 41.46))
        combinedShape.addCurve(to: CGPoint(x: 30.38, y: 49.52), controlPoint1: CGPoint(x: 29.98, y: 46.65), controlPoint2: CGPoint(x: 30.15, y: 48.09))
        combinedShape.addCurve(to: CGPoint(x: 56.43, y: 81.7), controlPoint1: CGPoint(x: 32.77, y: 64.48), controlPoint2: CGPoint(x: 42.52, y: 76.05))
        combinedShape.addCurve(to: CGPoint(x: 70.1, y: 84.43), controlPoint1: CGPoint(x: 60.67, y: 83.43), controlPoint2: CGPoint(x: 65.5, y: 84.25))
        combinedShape.addCurve(to: CGPoint(x: 93.84, y: 84.66), controlPoint1: CGPoint(x: 78.01, y: 84.74), controlPoint2: CGPoint(x: 85.93, y: 84.69))
        combinedShape.addCurve(to: CGPoint(x: 105.16, y: 84.64), controlPoint1: CGPoint(x: 97.64, y: 84.66), controlPoint2: CGPoint(x: 101.42, y: 84.64))
        combinedShape.close()
        combinedShape.move(to: CGPoint(x: 168, y: 84.64))
        combinedShape.addCurve(to: CGPoint(x: 162.5, y: 82.26), controlPoint1: CGPoint(x: 166.41, y: 84.64), controlPoint2: CGPoint(x: 163.91, y: 82.97))
        combinedShape.addCurve(to: CGPoint(x: 157.41, y: 79.3), controlPoint1: CGPoint(x: 160.75, y: 81.38), controlPoint2: CGPoint(x: 159.04, y: 80.39))
        combinedShape.addCurve(to: CGPoint(x: 149.1, y: 71.95), controlPoint1: CGPoint(x: 154.33, y: 77.23), controlPoint2: CGPoint(x: 151.52, y: 74.77))
        combinedShape.addCurve(to: CGPoint(x: 139.27, y: 50.7), controlPoint1: CGPoint(x: 144.06, y: 66.06), controlPoint2: CGPoint(x: 140.48, y: 58.36))
        combinedShape.addCurve(to: CGPoint(x: 138.15, y: 39.48), controlPoint1: CGPoint(x: 138.68, y: 46.99), controlPoint2: CGPoint(x: 138.51, y: 43.22))
        combinedShape.addCurve(to: CGPoint(x: 137.62, y: 35.16), controlPoint1: CGPoint(x: 138.02, y: 38.04), controlPoint2: CGPoint(x: 137.85, y: 36.6))
        combinedShape.addCurve(to: CGPoint(x: 111.57, y: 2.98), controlPoint1: CGPoint(x: 135.23, y: 20.2), controlPoint2: CGPoint(x: 125.48, y: 8.63))
        combinedShape.addCurve(to: CGPoint(x: 97.9, y: 0.25), controlPoint1: CGPoint(x: 107.33, y: 1.25), controlPoint2: CGPoint(x: 102.5, y: 0.43))
        combinedShape.addCurve(to: CGPoint(x: 74.15, y: 0.03), controlPoint1: CGPoint(x: 89.99, y: -0.06), controlPoint2: CGPoint(x: 82.07, y: -0.01))
        combinedShape.addCurve(to: CGPoint(x: 62.84, y: 0.04), controlPoint1: CGPoint(x: 70.36, y: 0.02), controlPoint2: CGPoint(x: 66.57, y: 0.04))
        combinedShape.addCurve(to: CGPoint(x: 68.34, y: 2.42), controlPoint1: CGPoint(x: 64.43, y: 0.04), controlPoint2: CGPoint(x: 66.93, y: 1.72))
        combinedShape.addCurve(to: CGPoint(x: 73.43, y: 5.38), controlPoint1: CGPoint(x: 70.1, y: 3.31), controlPoint2: CGPoint(x: 71.8, y: 4.29))
        combinedShape.addCurve(to: CGPoint(x: 81.74, y: 12.73), controlPoint1: CGPoint(x: 76.51, y: 7.45), controlPoint2: CGPoint(x: 79.32, y: 9.91))
        combinedShape.addCurve(to: CGPoint(x: 91.57, y: 33.98), controlPoint1: CGPoint(x: 86.78, y: 18.63), controlPoint2: CGPoint(x: 90.36, y: 26.32))
        combinedShape.addCurve(to: CGPoint(x: 92.69, y: 45.2), controlPoint1: CGPoint(x: 92.16, y: 37.7), controlPoint2: CGPoint(x: 92.33, y: 41.46))
        combinedShape.addCurve(to: CGPoint(x: 93.22, y: 49.52), controlPoint1: CGPoint(x: 92.82, y: 46.65), controlPoint2: CGPoint(x: 92.99, y: 48.09))
        combinedShape.addCurve(to: CGPoint(x: 119.27, y: 81.7), controlPoint1: CGPoint(x: 95.62, y: 64.48), controlPoint2: CGPoint(x: 105.37, y: 76.05))
        combinedShape.addCurve(to: CGPoint(x: 132.95, y: 84.43), controlPoint1: CGPoint(x: 123.52, y: 83.43), controlPoint2: CGPoint(x: 128.35, y: 84.25))
        combinedShape.addCurve(to: CGPoint(x: 156.68, y: 84.66), controlPoint1: CGPoint(x: 140.85, y: 84.74), controlPoint2: CGPoint(x: 148.77, y: 84.69))
        combinedShape.addCurve(to: CGPoint(x: 168, y: 84.64), controlPoint1: CGPoint(x: 160.48, y: 84.66), controlPoint2: CGPoint(x: 164.27, y: 84.64))
        combinedShape.close()
        combinedShape.move(to: CGPoint(x: 168, y: 84.64))
        combinedShape.lineWidth = 1.5
        UIColor(white: 0.8, alpha: 1).setStroke()
        combinedShape.stroke()
    }
 
}
