//
//  ScanViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/25/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

enum ProfileFields : Int {
    case name, title, email, phone
    
    var name : String {
        switch self {
            case .name: return "name"
            case .title: return "title"
            case .email: return "email"
            case .phone: return "phone"
        }
    }
    
    static func fields(_ response: CardResponse) -> [ProfileFields] {
        var fields = [ProfileFields]()
        if response.first_name || response.last_name { fields.append(.name) }
        if response.title { fields.append(.title) }
        if response.phone_number { fields.append(.phone) }
        if response.email { fields.append(.email) }

        return fields
    }
    
    var image : UIImage { return UIImage(named: name)! }
}

struct QRCard { var fields: [ProfileFields] }

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ViewPagerDelegate {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView = UIView().then {
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 2
    }
    var pager : ViewPager?
    let outline = UIView(translates: false).then {
        $0.backgroundColor = .clear
        $0.constrain(.height, constant: 190)
    }
    
    let editCard = EditCardView(UserResponse.current!).then {
        $0.alpha = 0.0
        $0.translates = false
    }
    
    var cards = CardResponse.cards?.map({ return QRCard(fields: ProfileFields.fields($0)) }) ?? [QRCard]()
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
            let qr = QRCardView(UserResponse.current!, fields: card.fields)
            let token = CardResponse.cards?.first?.token ?? ""
            qr.setToken((UserResponse.current?._id ?? "") + "::" + token)
            qr.pageControl.numberOfPages = min(cards.count + 1, 3)
            cardViews.append(qr)
        }
        
        cardViews.append(AddCardView(touchHandler: { self.add() }))
        
        pager = ViewPager(views: cardViews)
        pager?.delegate = self
        view.addSubview(pager!.scroll)
        pager?.scroll.translates = false
        pager?.scroll.constrain(.height, constant: 180)
        pager?.scroll.constrain(.width, .centerX, toItem: view)
        pager?.scroll.constrain(.top, constant: 105, toItem: view)
        pager?.scroll.clipsToBounds = false
        
        view.addSubview(outline)
        outline.constrain(.width, constant: -30, toItem: view)
        outline.constrain(.top, constant: 105, toItem: pager!.scroll, toAttribute: .bottom)
        outline.constrain(.centerX, toItem: view)
        
        editCard.cancelHandler = { self.edit() }
        editCard.doneHandler = { fields in self.update(fields) }
        
        if TARGET_OS_SIMULATOR == 1 { return }
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
            
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        } catch { print(error); return }
        
        view.bringSubview(toFront: pager!.scroll)
        view.bringSubview(toFront: outline)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        outline.addDashedBorder(.white)
        Snackbar(title: "Connected").presentIn(view: view)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            outline.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            outline.addDashedBorder(.white)
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
        qrCodeFrameView.frame = barCodeObject!.bounds
        
        guard let token = metadataObj.stringValue else { return }
        outline.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        outline.addDashedBorder(.green)
        guard presentedViewController == nil else { return }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        let alert = UIAlertController(title: "Code Found", message: token, preferredStyle: .alert)
        alert.addAction(UIAlertAction("Cancel", style: .cancel))
        present(alert)
        let tokenArray = token.components(separatedBy: "::")
        Client.execute(CardSyncRequest(_id: tokenArray[safe: 0] ?? "",
                                         my_token: CardResponse.cards?.first?.token ?? "",
                                         scanned_token: tokenArray[safe: 1] ?? ""),
                                         completionHandler: { response in
                                            print(response.result.value)
        })
    }
    
    func close() { dismiss() }
    
    func add(){
        cards.append(QRCard(fields: [.name, .title]))
        pager?.stack.arrangedSubviews.forEach({
            guard let qr = $0 as? QRCardView else { return }
            qr.pageControl.numberOfPages = min(cards.count + 1, 3)
        })
        let qr = QRCardView(UserResponse.current!, fields: [.name, .title])
        qr.pageControl.numberOfPages = min(cards.count + 1, 3)
        qr.pageControl.currentPage = pager!.previousPage
        pager?.insertView(qr, atIndex: pager!.previousPage)
        
        Client.execute(CardCreateRequest.new(), completionHandler: { response in
            guard let JSON = response.result.value as? JSONArray else { return }
            let array = JSON.map({ return CardResponse(JSON: $0) })
            print(array)
        })
        
        if cards.count == 3 { pager?.removeView(atIndex: 3) }
            
        if pager!.previousPage == cards.count - 1 && cards.count == 3 {
            self.pager!.currentView().fadeIn()
            
            pager?.selectedIndex(pager!.previousPage, animated: true)
        } else if pager!.previousPage == cards.count - 1 {
            self.pager!.currentView().fadeIn()
            
            pager?.selectedIndex(pager!.previousPage, animated: true)
        } else {
            pager?.selectedIndex(pager!.previousPage + 1, animated: true)
        }
    }
    
    func edit() {
        if editMode {
            UIView.animate(withDuration: 0.2, animations: {
                self.editCard.heightConstraint.constant = 180
                self.view.constraintFor(.centerY, toItem: self.editCard).constant = 0
                self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.editCard.fadeOut { self.editCard.removeFromSuperview() }
            })
            
            editMode = false
            pager?.scroll.isScrollEnabled = true
            return
        }
        editCard.removeConstraints(editCard.constraints)
        view.addSubview(editCard)
        
        let card = cards[(pager?.previousPage)!]
        self.editCard.fields = card.fields
        let current = pager?.currentView()

        editCard.constrain(.centerX, .centerY, .width, toItem: current!)
        editCard.constrain(.height, constant: 180)
        editCard.fadeIn(completion: {
                self.editCard.layoutIfNeeded()
                UIView.animate(withDuration: 0.2, animations: {
                    self.editCard.heightConstraint.constant = 255
                    self.view.constraintFor(.centerY, toItem: self.editCard).constant = 17
                    self.view.layoutIfNeeded()
                })
        })
        editMode = true
        pager?.scroll.isScrollEnabled = false
    }
    
    func update(_ fields: [ProfileFields]) {
        var card = self.cards[(self.pager?.previousPage)!]
        card.fields = fields
        
        guard let qr = self.pager?.currentView() as? QRCardView else { return }
        qr.updateFields(fields)
        
        self.edit()
        guard let cardResponse = CardResponse.cards?[safe: (self.pager?.previousPage)!] else { return }
        Client.execute(CardEditRequest(_id: cardResponse._id,
                                         first_name: fields.contains(.name),
                                         last_name: fields.contains(.name),
                                         email: fields.contains(.email),
                                         phone_number: fields.contains(.phone),
                                         title: fields.contains(.title)),
                         completionHandler: { _ in })
    }
    
    func delete() {
        let index = pager?.previousPage ?? 0
        pager?.removeView(atIndex: index)
        cards.remove(at: index)
        
        guard let cardResponse = CardResponse.cards?[safe: (self.pager?.previousPage)!] else { return }
        Client.execute(CardDeleteRequest(_id: cardResponse._id), completionHandler: { response in })
        
        pager?.stack.arrangedSubviews.forEach({
            guard let qr = $0 as? QRCardView else { return }
            qr.pageControl.numberOfPages = min(cards.count + 1, 3)
        })
        pager?.selectedIndex(index - 1, animated: true)
       
        for view in pager!.stack.arrangedSubviews {
            if view is AddCardView { return }
        }
        pager?.insertView(AddCardView(touchHandler: { self.add() }), atIndex: cards.count)

    }
    
    func selectedIndex(_ index: Int) {
        pager?.stack.arrangedSubviews.forEach({
            guard let qr = $0 as? QRCardView else { return }
            qr.pageControl.currentPage = index
        })
    }
    
    func overflow() {
        let add = UIAlertAction("Add Card", handler: { _ in self.add() })
        let edit = UIAlertAction("Edit Card", handler: { _ in self.edit() })
        let delete = UIAlertAction("Delete Card", handler: { _ in self.delete() })
        let cancel = UIAlertAction("Cancel", style: .cancel)
        
        let sheet = UIAlertController.sheet()
        
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

        present(sheet)
    }
}
