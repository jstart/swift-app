//
//  Card.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

enum CardType : String {
    case people = "people", tweet = "tweet", medium = "medium", skill = "skill", event = "event"
    
    func viewController() -> BaseCardViewController? {
        switch self {
        case .people: return PersonCardViewController()
        case .tweet: return TweetCardViewController()
        case .medium: return TweetCardViewController()
        case .event: return EventCardViewController()
        default: return nil }
    }
    
}

enum Content {
    case photo, article
}
