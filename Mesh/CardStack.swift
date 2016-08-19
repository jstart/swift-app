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
    var topCard : CardViewController = CardViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
        let person = Person(firstName: "", lastName:"", details: details)
        cards = [Card(type: .person, person: person)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        topCard.card = cards?.first
        cardViews = [topCard]

        let card = cardViews![0]
        card.delegate = self
        addCard(card)
    }
    
    func addNewCard() {
        topCard.card = cards?.first
        topCard.delegate = self
        cardViews?.append(topCard)
        addCard(topCard)
    }

    func addCard(_ card: CardViewController) {
        addChildViewController(card)
        card.view.alpha = CardFeedViewConfig().behindAlpha
        let scale = CardFeedViewConfig().behindScale
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        card.view.transform = transform;
        view.addSubview(card.view)
        
        card.view.constrain(.height, constant: -40, toItem: view)
        card.view.constrain(.width, constant: -13, toItem: view)
        card.view.constrain(.centerX, .centerY, toItem: view)
        card.view.translatesAutoresizingMaskIntoConstraints = false
        
        UIView.animate(withDuration: 0.2, animations: {
            card.view.alpha = 1.0
            let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            card.view.transform = transform;
        })
    }
    
    func showPreviousCard() {
        
    }
    
    func swiped(_ direction: UISwipeGestureRecognizerDirection) {
        addNewCard()
    }
}
