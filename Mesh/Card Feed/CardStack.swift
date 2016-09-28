//
//  CardStack.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

protocol CardDelegate { func swiped(_ direction: UISwipeGestureRecognizerDirection); func passCard(_ direction: UISwipeGestureRecognizerDirection) }

class CardStack : UIViewController, CardDelegate {
    
    var cards : [RecommendationResponse]? = nil
    var topCard = PersonCardViewController()
    var bottomCard = PersonCardViewController()
    var currentCard : BaseCardViewController?
    var cardIndex = 0
    
    func addNewCard() {
        let card = cards![cardIndex]
//        let next = cards![cardIndex + 1]

        switch card.cardType() {
        case .person:
//            bottomCard.card = next
//            bottomCard.delegate = self
//            addCard(bottomCard, animated: false)
            currentCard = topCard; break
        case .tweet:
            topCard.view.alpha = 0
            currentCard = TweetCardViewController(); break
        case .medium:
            topCard.view.alpha = 0
            currentCard = TweetCardViewController(); break
        case .event:
            topCard.view.alpha = 0
            currentCard = EventCardViewController(); break
        default: currentCard = nil; return }
        
        currentCard!.delegate = self
        addChildViewController(currentCard!)
        currentCard!.rec = card
        addCard(currentCard!)
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
        card.view.constrain((.height, -40), (.width, -13), toItem: view)
        card.view.constrain(.centerX, .centerY, toItem: view)
        card.view.translates = false
        
        if !animated { return }
        
        UIView.animate(withDuration: 0.2, animations: { card.view.alpha = 1.0; card.view.transform = .identity })
    }
    
    func showPreviousCard() { }
    
    func passCard(_ direction: UISwipeGestureRecognizerDirection) {
        switch direction {
        case UISwipeGestureRecognizerDirection.left:
            let card = self.currentCard!
            UIView.animate(withDuration: 0.5, animations: {
                card.view.transform = card.view.transform.rotated(by: (-45 * CGFloat(M_PI)) / 180).translatedBy(x: -(card.view.frame.size.width + 300), y: 100)
            }) { _ in self.currentCard!.view.removeFromSuperview(); self.swiped(direction) }
        default: return  }
    }
    
    func swiped(_ direction: UISwipeGestureRecognizerDirection) {
        let card = cards?[cardIndex]
        if let id = card?.user?._id { Client.execute(direction == .right ? LikeRequest(_id: id) : PassRequest(_id: id)) }
        
        if cardIndex + 5 == cards?.count {
            Client.execute(RecommendationsRequest(), complete: { response in
                guard let jsonArray = response.result.value as? JSONArray else { return }
                let array = jsonArray.map({return RecommendationResponse(JSON: $0)})
                self.cards?.append(contentsOf: array)
//                self.cards?.append(contentsOf: array.map({
//                    let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
//                    return Rec(type: .person, person: Person(user: $0, details: details), content: nil)
//                }))
            })
            cardIndex += 1
            addNewCard()
        } else if cardIndex + 1 == cards?.count {
            // Last card special case?
        } else {
            cardIndex += 1
            addNewCard()
        }
    }
}
