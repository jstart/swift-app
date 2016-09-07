//
//  CardStack.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

protocol CardDelegate { func swiped(_ direction: UISwipeGestureRecognizerDirection) }

class CardStack : UIViewController, CardDelegate {
    
    var cards : [Card]? = nil
    var topCard : CardViewController = CardViewController()
    var bottomCard : CardViewController = CardViewController()
    var cardIndex = 0
    
    func addNewCard() {
        let card = cards![cardIndex]
        switch card.type {
        case .person:
            topCard.card = card
            topCard.delegate = self
            addCard(topCard)
            break
        case .tweet:
            topCard.view.alpha = 0.0
            let tweet = TweetCardViewController()
            tweet.delegate = self
            addChildViewController(tweet)
            addCard(tweet)
        default: return
        }
    }

    func addCard(_ card: UIViewController, animated: Bool = true) {
        card.viewWillAppear(animated)
        card.view.alpha = CardFeedViewConfig().behindAlpha
        let scale = CardFeedViewConfig().behindScale
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        card.view.transform = transform;
        view.addSubview(card.view)
        addChildViewController(card)
        card.viewDidAppear(animated)
        card.view.constrain(.height, constant: -40, toItem: view)
        card.view.constrain(.width, constant: -13, toItem: view)
        card.view.constrain(.centerX, .centerY, toItem: view)
        card.view.translates = false
        
        if !animated { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            card.view.alpha = 1.0
            card.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func showPreviousCard() { }
    
    func swiped(_ direction: UISwipeGestureRecognizerDirection) {
        let card = cards?[cardIndex]
        guard let id = card?.person?.user?._id else {
            if cardIndex + 1 == cards?.count {
                cardIndex = 0
            } else {
                cardIndex += 1
            }
            addNewCard()
            return
        }
        let request : AuthenticatedRequest = direction == .right ? LikeRequest(_id: id) : PassRequest(_id: id)
        Client.execute(request) {_ in }
        
        if cardIndex + 1 == cards?.count {
            cardIndex = 0
        } else {
            cardIndex += 1
        }
        addNewCard()
    }
}
