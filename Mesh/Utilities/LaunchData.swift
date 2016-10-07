//
//  LaunchData.swift
//  Mesh
//
//  Created by Christopher Truman on 9/11/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import RealmSwift

struct LaunchData {
    
    static func fetchLaunchData() {
        fetchCards(); fetchUpdates()
    }
    
    static func fetchCards() {
        Client.execute(CardsRequest(), complete: { response in
            DispatchQueue.global(qos: .background).async {
                guard let JSON = response.result.value as? JSONArray else { return }
                let cards = JSON.map({ return CardResponse(JSON: $0) })
                guard cards.count != 0 else { Client.execute(CardCreateRequest.new(), complete: { response in
                    guard let JSON = response.result.value as? JSONArray else { return }
                    JSON.forEach({ UserResponse.cards = [CardResponse(JSON: $0)] })
                }); return }
                UserResponse.cards = cards
            }
        })
    }
    
    static func fetchUpdates() {
        Client.execute(UpdatesRequest.fresh(), complete: { response in
            UserResponse.connections = []; UserResponse.messages = []
            UpdatesRequest.append(response)
        })
    }
}
