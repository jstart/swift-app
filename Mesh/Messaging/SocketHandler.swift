//
//  SocketHandler.swift
//  Mesh
//
//  Created by Christopher Truman on 10/6/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import SocketIO

extension Notification.Name {
    static let typing = NSNotification.Name("Typing")
    static let message = NSNotification.Name("Message")
}

class SocketHandler {
    
    static let shared = SocketHandler()
    let socket = SocketIOClient(socketURL: URL(string: "http://dev.mesh.tinderventures.com:2222")!, config: [.extraHeaders(["token" : Token.retrieveToken() ?? ""])])
    var typing : Date?
    
    static func startListening() {
        shared.socket.on("connect") { data, ack in
            print("socket connected")
            shared.socket.emit("alive", with: [""])
        }
        
        shared.socket.on("typing") { data, ack in
            DefaultNotification.post(name: .typing, object: data.first)
        }
        
        shared.socket.on("message") { data, ack in
            DefaultNotification.post(name: .message, object: data.first)
        }

        shared.socket.on("alive") { data, ack in
            print(data)
        }
        
        shared.socket.on("error") { data, ack in
            print(data)
        }
        
        shared.socket.on("disconnect") { data, ack in
            print(data)
        }
        
        shared.socket.connect()
    }
    
    static func sendTyping(userID: String) {
        if shared.typing == nil || shared.typing?.timeIntervalSinceNow ?? 0 < -2.5 {
            shared.typing = Date()
            shared.socket.emit("typing", with: [["_id": userID]])
        }
    }
    
    static func stopListening() {
        shared.socket.disconnect()
    }
    
}
