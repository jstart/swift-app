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
        fetchCards(); fetchUpdates()
    }
    
    static func fetchCards() {
        Client.execute(CardsRequest(), complete: { response in
            DispatchQueue.global(qos: .background).async {
                guard let JSON = response.result.value as? JSONArray else { return }
                let cards = JSON.map({ return Card(JSON: $0) })
                guard cards.count != 0 else { Client.execute(CardCreateRequest.new(), complete: { response in
                    guard let JSON = response.result.value as? JSONArray else { return }
                    JSON.forEach({ let _ = Card(JSON: $0) })
                }); return }
                CardResponse.cards = cards
            }
        })
    }
    
    static func fetchUpdates() {
        Client.execute(UpdatesRequest.fresh(), complete: { response in
            UserResponse.connections = []; UserResponse.messages = []
            UpdatesRequest.append(response)
            
            CoreData.backgroundContext.perform({
                guard let json = response.result.value as? JSONDictionary else { return }
                if let messages = (json["messages"] as? JSONDictionary)?["messages"] as? JSONArray {
                    messages.forEach({let _ = Message(JSON: $0)})
                }
                if let connections = (json["connections"] as? JSONDictionary)?["connections"] as? JSONArray {
                    connections.forEach({let _ = Connection(JSON: $0)})
                }
                CoreData.saveBackgroundContext()
            })
        })
    }
}
