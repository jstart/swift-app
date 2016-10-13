//
//  CardStack.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

protocol CardDelegate {
    func swiped(_ direction: UISwipeGestureRecognizerDirection)
    func passCard(_ direction: UISwipeGestureRecognizerDirection)
    func swiping(percent: CGFloat)
}

class CardStack : UIViewController, CardDelegate {
    
    var cards : [RecommendationResponse]? = nil
    var bottomCard : BaseCardViewController?
    var currentCard : BaseCardViewController?
    var cardIndex = 0
    
    func stopAnimation() {
        view.layer.sublayers?.removeAll()
    }
    
    func animate() {
        let circleSpacing: CGFloat = 2
        let size = CGSize(width: 40, height: 40)
        let circleSize = (size.width - circleSpacing * 2) / 3
        let x = (view.frame.size.width - size.width) / 2
        let y = (view.frame.size.height - size.height - 88 - 88) / 2
        let durations: [CFTimeInterval] = [0.72, 1.02, 1.28, 1.42, 1.45, 1.18, 0.87, 1.45, 1.06]
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [-0.06, 0.25, -0.17, 0.48, 0.31, 0.03, 0.46, 0.78, 0.45]
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.5, 1]
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.keyTimes = [0, 0.5, 1]
        opacityAnimation.timingFunctions = [timingFunction, timingFunction]
        opacityAnimation.values = [1, 0.7, 1]
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, opacityAnimation]
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                let circle = NVActivityIndicatorShape.circle.layerWith(size: CGSize(width: circleSize, height: circleSize), color: .lightGray)
                let frame = CGRect(x: x + circleSize * CGFloat(j) + circleSpacing * CGFloat(j),
                                   y: y + circleSize * CGFloat(i) + circleSpacing * CGFloat(i),
                                   width: circleSize, height: circleSize)
                animation.duration = durations[3 * i + j]
                animation.beginTime = beginTime + beginTimes[3 * i + j]
                circle.frame = frame
                circle.add(animation, forKey: "animation")
                view.layer.addSublayer(circle)
            }
        }
    }
    
    func addNewCard() {
        let card = cards![cardIndex]
        let next = cards![safe: cardIndex + 1]
        if bottomCard == nil {
            currentCard = card.cardType().viewController()
            currentCard?.delegate = self
            addChildViewController(currentCard!)
            currentCard?.rec = card
            bottomCard?.viewDidLayoutSubviews()
            currentCard?.view.alpha = 0
            let scale = CardFeedViewConfig().behindScale
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            currentCard?.view.transform = transform;
        } else {
            currentCard = bottomCard
        }
        guard let cardType = next?.cardType() else { addCard(currentCard!); bottomCard = nil; return }
        bottomCard = cardType.viewController()
        bottomCard?.delegate = self
        addChildViewController(bottomCard!)
        bottomCard?.rec = next
        bottomCard?.viewDidLayoutSubviews()
        bottomCard?.view.alpha = 0
        addCard(currentCard!)
    }

    func addCard(_ card: UIViewController, animated: Bool = true) {
        card.viewWillAppear(animated)
        view.addSubview(card.view)
        addChildViewController(card)
        card.viewDidAppear(animated)
        card.view.constrain((.width, -13), toItem: view)
        card.view.constrain(.height, relatedBy: .lessThanOrEqual, constant: -40, toItem: view)
        card.view.constrain(.centerX, .centerY, toItem: view)
        card.view.translates = false
        
        if !animated { view.sendSubview(toBack: card.view); return }
        UIView.animate(withDuration: 0.2, animations: { card.view.alpha = 1.0; card.view.transform = .identity }, completion: { _ in
            guard self.bottomCard != nil else { return }
            self.addCard(self.bottomCard!, animated: false)
        })
    }
    
    func showPreviousCard() { }
    
    func passCard(_ direction: UISwipeGestureRecognizerDirection) {
        switch direction {
        case UISwipeGestureRecognizerDirection.left:
            let card = self.currentCard!
            UIView.animate(withDuration: 0.5, animations: {
                card.view.transform = card.view.transform.rotated(by: (-45 * CGFloat(M_PI)) / 180).translatedBy(x: -(card.view.frame.size.width + 300), y: 100)
            }) { _ in self.currentCard!.view.removeFromSuperview(); self.swiped(direction) }
        default: return }
    }
    
    func swiped(_ direction: UISwipeGestureRecognizerDirection) {
        let card = cards?[cardIndex]
        
        switch card!.cardType() {
        case .people: if let id = card?.user?._id { Client.execute(direction == .right ? LikeRequest(_id: id) : PassRequest(_id: id)) }
        case .event: if let id = card?.event?._id { Client.execute(direction == .right ? EventLikeRequest(_id: id) : EventPassRequest(_id: id)) }
        default: break }
        
        if cardIndex + 5 == cards?.count {
            Client.execute(RecommendationsRequest(), complete: { response in
                guard let jsonArray = response.result.value as? JSONArray else { return }
                let array = jsonArray.map({ return RecommendationResponse.create($0) })
                /*let realm = RealmUtilities.realm()
                try! realm.write {
                    realm.delete(realm.objects(RecommendationResponse.self))
                    realm.add(array)
                }*/
                self.cards?.append(contentsOf: array)
            })
        }
        
        if cardIndex + 1 == cards?.count {
            // Last card special case?
        } else {
            cardIndex += 1
            addNewCard()
        }
    }
    
    func swiping(percent: CGFloat) {
        bottomCard?.view.alpha = percent
        let scale = min(1, (percent)/1)
        bottomCard?.view.transform = CGAffineTransform.init(scaleX: scale, y: scale)
    }
    
}
