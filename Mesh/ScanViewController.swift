    //
//  ScanViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/25/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import AVFoundation
//import Shimmer
    
struct QRCard {
    var index : Int
    // fields
}

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
    
    let editCard = EditCardView(UserResponse.currentUser!).then {
        $0.alpha = 0.0
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var cards = [QRCard(index:0)]
    var editMode : Bool = false
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

        var cardViews = [UIView]()
        for card in cards {
           cardViews.append(QRCardView(UserResponse.currentUser!))
        }
        
        cardViews.append(AddCardView(touchHandler: { self.add() }))
        
        pager = ViewPager(views: cardViews)
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
        
        editCard.cancelHandler = {
            self.edit()
        }
        
        editCard.doneHandler = {
            self.edit()
        }
        
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
            guard presentedViewController == nil else { return }
            print(metadataObj.stringValue)
            let alert = UIAlertController(title: "Code Found", message: metadataObj.stringValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func add(){
        cards.append(QRCard(index: 1))
        pager?.insertView(QRCardView(UserResponse.currentUser!), atIndex: pager!.previousPage)
        
        if cards.count == 3 {
            pager?.removeView(atIndex: 3)
        }
            
        if pager!.previousPage == cards.count - 1 && cards.count == 3 {
            let view = self.pager!.currentView()
            view.alpha = 0.0
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 1.0
            })
            pager?.selectedIndex(pager!.previousPage, animated: true)
        } else if pager!.previousPage == cards.count - 1 {
            let view = self.pager!.currentView()
            view.alpha = 0.0
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 1.0
            })
            pager?.selectedIndex(pager!.previousPage, animated: true)
        } else {
            pager?.selectedIndex(pager!.previousPage + 1, animated: true)
        }
    }
    
    func edit() {
        let current = pager?.currentView()

        if editMode {
            UIView.animate(withDuration: 0.2, animations: {
                self.editCard.heightConstraint.constant = 180
                self.view.constraintFor(attribute: .centerY, toItem: self.editCard).constant = 0
                self.view.layoutIfNeeded()
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.editCard.alpha = 0.0
                        }, completion: { _ in
                            self.editCard.removeFromSuperview()
                    })
            })
            
            editMode = false
            pager?.scroll.isScrollEnabled = true
            return
        }
        editCard.removeConstraints(editCard.constraints)
        view.addSubview(editCard)
        
        editCard.constrain(.centerX, .centerY, .width, toItem: current!)
        editCard.constrain(.height, constant: 180)
        UIView.animate(withDuration: 0.2, animations: {
            self.editCard.alpha = 1.0
            }, completion: { _ in
                self.editCard.layoutIfNeeded()
                UIView.animate(withDuration: 0.2, animations: {
                    self.editCard.heightConstraint.constant = 255
                    self.view.constraintFor(attribute: .centerY, toItem: self.editCard).constant = 17
                    self.view.layoutIfNeeded()
                })
        })
        editMode = true
        pager?.scroll.isScrollEnabled = false
    }
    
    func delete() {
        let index = pager?.previousPage ?? 0
        pager?.removeView(atIndex: index)
        cards.remove(at: index)
        pager?.selectedIndex(index - 1, animated: true)
        
        for view in pager!.stack.arrangedSubviews {
            if view is AddCardView { return }
        }
        pager?.insertView(AddCardView(touchHandler: {
            self.add()
        }), atIndex: cards.count)
    }
    
    func overflow() {
        let add = UIAlertAction(title: "Add Card", style: .default, handler: { _ in
            self.add()
        })
        let edit = UIAlertAction(title: "Edit Card", style: .default, handler: { _ in
            self.edit()
        })
        let delete = UIAlertAction(title: "Delete Card", style: .default, handler: { _ in
            self.delete()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let view = pager?.currentView()
        if view is AddCardView {
            sheet.addActions(add, cancel)
        } else {
            if pager?.previousPage == 0 && cards.count < 3 {
                sheet.addActions(add, edit, cancel)
            } else if pager?.previousPage == 0 && cards.count == 3 {
                sheet.addActions(edit, cancel)
            } else if cards.count > 1 && cards.count < 3 {
                sheet.addActions(add, edit, delete, cancel)
            } else {
                sheet.addActions(edit, delete, cancel)
            }
        }

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
