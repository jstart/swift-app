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
    var name: String { switch self { case .name: return "name"; case .title: return "title"; case .email: return "email"; case .phone: return "phone" } }
    
    static func fields(_ response: CardResponse) -> [ProfileFields] {
        var fields = [ProfileFields]()
        if response.first_name || response.last_name { fields.append(.name) }
        if response.title { fields.append(.title) }
        if response.phone_number { fields.append(.phone) }
        if response.email { fields.append(.email) }
        return fields
    }
    
    var image: UIImage { return UIImage(named: name)! }
}

struct QRCard { var fields: [ProfileFields], token: String }

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ViewPagerDelegate {
    
    let captureSession = AVCaptureSession()
    let captureMetadataOutput = AVCaptureMetadataOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var pager : ViewPager?
    let outline = OutlineView()
    var overlay : UIView?
    
    let editCard = EditCardView(UserResponse.current!).then { $0.translates = false }
    var cards = CardResponse.cards?.map({ return QRCard(fields: ProfileFields.fields($0), token: $0.token) }) ?? [QRCard]()
    var editMode : Bool = false
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        title = "Share Contact Card"
        navigationItem.leftBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "backArrow"), target: self, action: #selector(dismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(#imageLiteral(resourceName: "connectionsOverflow"), target: self, action: #selector(overflow))
        automaticallyAdjustsScrollViewInsets = false

        var cardViews = [UIView]()
        for card in cards {
            let qr = QRCardView(UserResponse.current!, fields: card.fields)
            qr.tapAction = { self.edit() }
            qr.setToken((UserResponse.current?._id ?? "") + "::" + card.token)
            qr.pageControl.numberOfPages = min(cards.count + 1, 3)
            cardViews.append(qr)
        }
        if cards.count < 3 { cardViews.append(AddCardView(touchHandler: { self.add() })) }
        
        pager = ViewPager(views: cardViews)
        pager?.delegate = self
        view.addSubview(pager!.scroll)
        pager?.scroll.translates = false
        pager?.scroll.constrain(.height, constant: 180)
        pager?.scroll.constrain(.width, .centerX, toItem: view)
        pager?.scroll.constrain(.top, constant: 105, toItem: view)
        
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
            
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
        } catch { print(error); return }
        
        view.bringSubview(toFront: pager!.scroll)
        view.bringSubview(toFront: outline)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        if showOverlayFirstTime() { return }
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        guard UserDefaults.standard["FirstScan"] == nil else { return }
        Snackbar(title: "Hover over another card to scan and connect", showUntilDismissed: true).presentIn(view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if videoPreviewLayer != nil {
            captureMetadataOutput.rectOfInterest = videoPreviewLayer!.metadataOutputRectOfInterest(for: outline.frame)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count == 0 { return }
        captureSession.stopRunning()
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard let token = metadataObj.stringValue else { return }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        let tokenArray = token.components(separatedBy: "::")
        let request = CardSyncRequest(_id: tokenArray[safe: 0] ?? "",
                                      my_token: CardResponse.cards?.first?.token ?? "",
                                      scanned_token: tokenArray[safe: 1] ?? "")
        Client.execute(request, completionHandler: { response in
            if response.result.value != nil {
                Snackbar(title: "Connected!", buttonTitle: "VIEW PROFILE", buttonHandler: {}).presentIn(self.view)
                UserDefaults.standard.set(true, forKey: "FirstScan")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.captureSession.startRunning()
            })
            if response.result.value == nil {
                Snackbar(title: "Scanning Failed", buttonTitle: "RETRY", buttonHandler: {}).presentIn(self.view)
            }
        })
    }
    
    func refresh() {
        Client.execute(CardsRequest(), completionHandler: { response in
            CardResponse.cards = (response.result.value as? JSONArray)?.map({ return CardResponse(JSON: $0) })
            self.cards = CardResponse.cards?.map({ return QRCard(fields: ProfileFields.fields($0), token: $0.token) }) ?? [QRCard]()
            for (index, card) in self.pager!.stack.arrangedSubviews.enumerated() {
                (card as? QRCardView)?.setToken((UserResponse.current?._id ?? "") + "::" + self.cards[index].token, animated: true)
            }
        })
    }
    
    func add(){
        cards.append(QRCard(fields: [.name, .title], token: ""))
        pager?.stack.arrangedSubviews.forEach({
            ($0 as? QRCardView)?.pageControl.numberOfPages = min(cards.count + 1, 3)
        })
        let qr = QRCardView(UserResponse.current!, fields: [.name, .title])
        qr.tapAction = { self.edit() }
        qr.pageControl.numberOfPages = min(cards.count + 1, 3)
        qr.pageControl.currentPage = pager!.previousPage
        pager?.insertView(qr, atIndex: pager!.previousPage)
        
        Client.execute(CardCreateRequest.new(), completionHandler: { response in //let array = (response.result.value as? JSONArray)?.map({ return CardResponse(JSON: $0) }) 
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
                }, completion: { _ in self.editCard.fadeOut { self.editCard.removeFromSuperview() } })
            editMode = false
            pager?.scroll.isScrollEnabled = true
            return
        }
        editCard.removeConstraints(editCard.constraints)
        view.addSubview(editCard)
        
        let card = cards[(pager?.previousPage)!]
        self.editCard.fields = card.fields

        editCard.constrain(.centerX, .centerY, .width, toItem: pager?.currentView())
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
        
        (self.pager?.currentView() as? QRCardView)?.updateFields(fields)
        
        self.edit()
        guard let cardResponse = CardResponse.cards?[safe: (self.pager?.previousPage)!] else { return }
        let snack = Snackbar(title: "Saving Card..."); snack.presentIn(view)
        let request = CardEditRequest(_id: cardResponse._id, first_name: fields.contains(.name), last_name: fields.contains(.name), email: fields.contains(.email), phone_number: fields.contains(.phone), title: fields.contains(.title))
        Client.execute(request, completionHandler: { _ in
            snack.message.text = "Card Updated"
            Client.execute(CardsRequest(), completionHandler: { response in
                guard let JSON = response.result.value as? JSONArray else { return }
                CardResponse.cards = JSON.map({ return CardResponse(JSON: $0) })
                self.cards = CardResponse.cards?.map({ return QRCard(fields: ProfileFields.fields($0), token: $0.token) }) ?? [QRCard]()
                self.refresh()
            })
        })
    }
    
    func delete() {
        let index = pager?.previousPage ?? 0
        pager?.removeView(atIndex: index)
        cards.remove(at: index)
        
        guard let cardResponse = CardResponse.cards?[safe: index] else { return }
        Snackbar(title: "Card Deleted", buttonTitle: "UNDO", dismissed: {
            Client.execute(CardDeleteRequest(_id: cardResponse._id), completionHandler: { response in })
        }).presentIn(self.view)
        
        pager?.stack.arrangedSubviews.forEach({ ($0 as? QRCardView )?.pageControl.numberOfPages = min(cards.count + 1, 3) })
        pager?.selectedIndex(index - 1, animated: true)
       
        for view in pager!.stack.arrangedSubviews { if view is AddCardView { return } }
        pager?.insertView(AddCardView(touchHandler: { self.add() }), atIndex: cards.count)
    }
    
    func selectedIndex(_ index: Int) {
        pager?.stack.arrangedSubviews.forEach { ($0 as? QRCardView)?.pageControl.currentPage = index }
    }
    
    func overflow() {
        let add = UIAlertAction("Add Card") { _ in self.add() }
        let edit = UIAlertAction("Edit Card") { _ in self.edit() }
        let delete = UIAlertAction("Delete Card") { _ in self.delete() }
        let cancel = UIAlertAction.cancel()
        let sheet = UIAlertController.sheet()
        
        let view = pager?.currentView()
        if view is AddCardView { sheet.addActions(add, cancel) } else {
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
    
    
    func showOverlayFirstTime() -> Bool {
        if UserDefaults.standard["DefaultCard"] == nil && cards.count <= 1 {
            pager?.scroll.isScrollEnabled = false
            overlay = UIView(translates: false).then {
                $0.backgroundColor = .black
                $0.alpha = 0.85
            }
            guard let overlay = overlay else { return false }
            
            view.addSubview(overlay)
            overlay.constrain(.height, .width, .centerX, .centerY, toItem: view)
            view.bringSubview(toFront: pager!.scroll)
            
            let header = UILabel(translates: false).then {
                $0.font = .boldSystemFont(ofSize: 20)
                $0.textColor = .white
                $0.text = "Auto Created Card"
                $0.textAlignment = .center
                $0.constrain((.height, 25))
            }
            
            overlay.addSubview(header)
            header.constrain(.centerX, .leading, .trailing, toItem: view)
            header.constrain(.top, constant: 30, toItem: pager?.scroll, toAttribute: .bottom)
            
            let message = UILabel(translates: false).then {
                $0.font = .systemFont(ofSize: 16)
                $0.numberOfLines = 0
                $0.textColor = .white
                $0.text = "We’ve created your virtual business card to share with others. Everything look OK?"
                $0.textAlignment = .center
            }
            
            overlay.addSubview(message)
            message.constrain(.centerX, toItem: view)
            message.constrain(.leading, constant: 40,  toItem: view)
            message.constrain(.trailing, constant: -40,  toItem: view)
            message.constrain(.top, constant: 5, toItem: header, toAttribute: .bottom)
            
            let edit = UIButton(translates: false).then {
                $0.setTitle("EDIT", for: .normal)
                $0.layer.borderColor = UIColor.white.cgColor
                $0.layer.borderWidth = 1.0
                $0.layer.cornerRadius = 5.0
                $0.constrain((.width, 90), (.height, 30))
            }
            edit.addTarget(self, action: #selector(editAndDismiss), for: .touchUpInside)
            
            overlay.addSubview(edit)
            edit.constrain(.top, constant: 35, toItem: message, toAttribute: .bottom)
            edit.constrain(.centerX, constant: -(25 + (90 / 2)), toItem: view)
            
            let yes = UIButton(translates: false).then {
                $0.setTitle("YES", for: .normal)
                $0.setTitleColor(Colors.brand, for: .normal)
                $0.layer.borderColor = Colors.brand.cgColor
                $0.layer.borderWidth = 1.0
                $0.layer.cornerRadius = 5.0
                $0.constrain((.width, 90), (.height, 30))
            }
            yes.addTarget(self, action: #selector(dismissOverlay), for: .touchUpInside)
            
            overlay.addSubview(yes)
            yes.constrain(.top, constant: 35, toItem: message, toAttribute: .bottom)
            yes.constrain(.centerX, constant: (25 + (90 / 2)), toItem: view)
            return true
        }
        return false
    }
    
    func editAndDismiss() {
        self.edit()
        self.dismissOverlay()
    }
    
    func dismissOverlay() {
        UserDefaults.standard.set(true, forKey: "DefaultCard")
        if overlay != nil {
            timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        }
        pager?.scroll.isScrollEnabled = true
        overlay?.fadeOut() { self.overlay?.removeFromSuperview() }
        
        guard UserDefaults.standard["FirstScan"] == nil else { return }
        Snackbar(title: "Hover over another card to scan and connect", showUntilDismissed: true).presentIn(view)
    }
}
