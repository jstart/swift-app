//
//  LaunchData.swift
//  Mesh
//
//  Created by Christopher Truman on 9/11/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation

struct LaunchData {
    
    static func fetchLaunchData() {
        fetchCards()
        fetchUpdates()
    }
    
    static func fetchCards() {
        Client.execute(CardsRequest(), completionHandler: { response in
            DispatchQueue.global(qos: .background).async {
                guard let JSON = response.result.value as? JSONArray else { return }
                let cards = JSON.map({ return Card(JSON: $0) })
                guard cards.count != 0 else { Client.execute(CardCreateRequest.new(), completionHandler: { response in
                    guard let JSON = response.result.value as? JSONArray else { return }
                    JSON.forEach({ let _ = Card(JSON: $0) })
                }); return }
                CardResponse.cards = cards
            }
        })
    }
    
    static func fetchUpdates() {
        Client.execute(UpdatesRequest.fresh(), completionHandler: { response in
            UserResponse.connections = []
            UserResponse.messages = []
            UpdatesRequest.append(response)
        })
    }
}
