//
//  SocketHandler.swift
//  Mesh
//
//  Created by Christopher Truman on 10/6/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import SocketIO

class SocketHandler {
    
    static let shared = SocketHandler()
    let socket = SocketIOClient(socketURL: URL(string: "http://dev.mesh.tinderventures.com:2222")!, config: [.extraHeaders(["token" : Token.retrieveToken() ?? ""])])
    
    static func startListening() {
        shared.socket.on("connect") {data, ack in
            print("socket connected", data)
            shared.socket.emit("alive", with: [""])
        }

        shared.socket.on("alive-ack") { data, ack in
            print(data)
            //ack.with([""])
        }
        
        shared.socket.on("disconnect") { data, ack in
            print(data)
        }
        
        shared.socket.connect()
    }
    
    static func stopListening() {
        shared.socket.disconnect()
    }
    
}
