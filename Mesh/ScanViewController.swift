    //
//  ScanViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/25/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import AVFoundation
import Shimmer

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView = UIView().then {
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 2
    }
    var pager : ViewPager?
    let outline = UIView().then {
        $0.backgroundColor = .clear
        $0.constrain(.height, constant: 190)
    }
    
    let supportedBarCodes = [AVMetadataObjectTypeQRCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        title = "Share Contact Card"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "backArrow"), style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "connectionsOverflow"), style: .plain, target: self, action: #selector(overflow))

        pager = ViewPager(views: [cardView(), cardView()])
        view.addSubview(pager!.scroll)
        pager?.scroll.translatesAutoresizingMaskIntoConstraints = false
        pager?.scroll.constrain(.height, constant: 180)
        pager?.scroll.constrain(.width, .centerX, toItem: view)
        pager?.scroll.constrain(.top, constant: 105, toItem: view)
        pager?.scroll.clipsToBounds = false
        
        
        view.addSubview(outline)
        outline.translatesAutoresizingMaskIntoConstraints = false
        outline.constrain(.width, constant: -30, toItem: view)
        outline.constrain(.top, constant: 105, toItem: pager!.scroll, toAttribute: .bottom)
        outline.constrain(.centerX, toItem: view)
        
        /*let shimmer = FBShimmeringView()
        view.addSubview(shimmer)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.constrain(.width, .height, .centerX, .centerY, toItem: outline)
        shimmer.contentView = outline
        shimmer.isShimmering = true*/

        if TARGET_OS_SIMULATOR == 1 {
            return
        }
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        } catch {
            print(error)
            return
        }
        view.bringSubview(toFront: pager!.scroll)
        view.bringSubview(toFront: outline)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        outline.addDashedBorder(color: .white)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            outline.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            outline.addDashedBorder(color: .white)
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
        qrCodeFrameView.frame = barCodeObject!.bounds
        
        if metadataObj.stringValue != nil {
            outline.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            outline.addDashedBorder(color: .green)
            print(metadataObj.stringValue)
            guard presentedViewController == nil else { return }
            let alert = UIAlertController(title: "Code Found", message: metadataObj.stringValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func cardView() -> UIView {
        return UIView().then {
            $0.layer.shadowColor = UIColor.darkGray.cgColor
            $0.layer.shadowOpacity = 0.75
            $0.layer.shadowRadius = 5
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 5
            $0.constrain(.height, constant: 180)
        }
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func overflow() {
        let add = UIAlertAction(title: "Add Card", style: .default, handler: { _ in
            
        })
        let edit = UIAlertAction(title: "Edit Card", style: .default, handler: { _ in
            
        })
        let delete = UIAlertAction(title: "Delete Card", style: .default, handler: { _ in
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addActions(add, edit, delete, cancel)

        present(sheet, animated: true, completion: nil)
    }
}

extension UIView {
    func addDashedBorder(color: UIColor) {
        let shapeLayer = CAShapeLayer()
        let frameSize = frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineJoin = kCALineJoinMiter
        shapeLayer.lineDashPattern = [10,12]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).cgPath
        
        layer.addSublayer(shapeLayer)
    }
}
