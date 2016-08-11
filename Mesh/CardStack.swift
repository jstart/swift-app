//
//  CardStack.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

protocol CardDelegate {
    func swiped(_ direction:UISwipeGestureRecognizerDirection)
}

class CardStack : UIViewController, CardDelegate {
    
    var cards : [Card]? = nil
    private var cardViews : [CardViewController]? = nil
    var topCard : CardViewController? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let loading = Loading(viewController: self, activityStyle: ActivityStyle(style: .gray, position: .center))
        //loading.addLoadingView()
        //loading.start()
        
        if (cardViews?[0] != nil) {
            return
        }else {
            cardViews = [CardViewController()]
        }
        let card = cardViews![0]
        card.delegate = self
        addCard(card)
        
//        let nextCard = CardViewController()
//        cardViews?.append(nextCard)
//        addCard(card: nextCard)
    }
    
    func addNewCard(){
        let nextCard = CardViewController()
        nextCard.delegate = self
        cardViews?.append(nextCard)
        addCard(nextCard)
    }

    func addCard(_ card: CardViewController){
        addChildViewController(card)
        card.view.alpha = CardFeedViewConfig().behindAlpha
        let scale = CardFeedViewConfig().behindScale
        let transform =
            CGAffineTransform(scaleX: scale, y: scale)
        card.view.transform = transform;
        view.addSubview(card.view)
        
        NSLayoutConstraint(item: card.view, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant:-60).isActive = true
        NSLayoutConstraint(item: card.view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant:-20).isActive = true
        
        view.centerXAnchor.constraint(equalTo: card.view.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: card.view.centerYAnchor).isActive = true
        
        card.view.translatesAutoresizingMaskIntoConstraints = false
        
        UIView.animate(withDuration: 0.2, animations: {
            card.view.alpha = 1.0
            let transform =
                CGAffineTransform(scaleX: 1.0, y: 1.0)
            card.view.transform = transform;
        })
    }
    
    func showPreviousCard(){
        
    }
    
    func swiped(_ direction: UISwipeGestureRecognizerDirection) {
        addNewCard()
    }
}
