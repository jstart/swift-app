//
//  CameraManager.swift
//  Mesh
//
//  Created by Christopher Truman on 8/18/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraManager : NSObject {
    
    static func authStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    }
    
    static func requestAccess(completionHandler: ((Bool) -> Void)) {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch status {
        case .authorized:
            completionHandler(true)
            break
        case .denied:
            fallthrough
        case .restricted:
            let alertController = UIAlertController(
                title: "Camera Access Disabled",
                message: "In order to scan your card, we need to access the Camera. ",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
                UIApplication.shared.openURL(url as URL)
            }
            alertController.addAction(openAction)
            
            UIApplication.shared.keyWindow!.rootViewController!.present(alertController, animated: true, completion: nil)

            completionHandler(false)
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { granted in
                completionHandler(granted)
            })
        }
    }
    
}
