//
//  SocketHandler.swift
//  Mesh
//
//  Created by Christopher Truman on 10/6/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import SocketIO
import UserNotifications

extension Notification.Name {
    static let typing = NSNotification.Name("Typing")
    static let message = NSNotification.Name("Message")
    static let connection = NSNotification.Name("Connection")
}

class SocketHandler {
    
    static let shared = SocketHandler()
    let socket = SocketIOClient(socketURL: URL(string: "http://dev.mesh.tinderventures.com:2222")!, config: [.extraHeaders(["token" : Token.retrieveToken() ?? ""])])
    var typing : Date?
    
    static func startListening() {
        shared.socket.removeAllHandlers()
        shared.socket.on("connect") { data, ack in print("socket connected"); shared.socket.emit("alive", with: [""]) }
        
        shared.socket.on("typing") { data, ack in DefaultNotification.post(name: .typing, object: data.first) }
        
        shared.socket.on("message") { data, ack in
            guard let message = data.first as? JSONDictionary else { return }
            let meshMessage = MessageResponse.create(message)
            let realm = RealmUtilities.realm()
            
            var messageConnection : ConnectionResponse?
            for connection in UserResponse.connections {
                if connection.user?._id == meshMessage.sender {
                    messageConnection = connection
                }
            }
            
            try! realm.write { realm.add(meshMessage, update: true); messageConnection?.read = false }
            UserResponse.messages = Array(realm.objects(MessageResponse.self)).sorted(by: { $0.ts > $1.ts });
            DefaultNotification.post(name: .message, object: message)
            let alert = TopAlert(title: "New Message", content: meshMessage.text!, imageURL: messageConnection!.user!.photos!.large!, duration: 5)
            alert.actions = [AlertAction(title: "Reply", handler: {
                let tab = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController
                tab?.presentedViewController?.dismiss()
                tab?.selectedIndex = 1
                alert.dismiss()
            })]
            alert.presentIn(UIApplication.shared.delegate!.window!)

            /*if UIApplication.shared.applicationState == .background {
                let notification = UILocalNotification()
                notification.alertBody = (messageConnection?.user?.fullName())! + ": " + meshMessage.text!
                notification.alertAction = "Open"
                notification.fireDate = Date()
                notification.soundName = UILocalNotificationDefaultSoundName
                //notification.userInfo = ["message": meshMessage]
                
                UIApplication.shared.scheduleLocalNotification(notification)
            }*/
        }
        
        shared.socket.on("connection") { data, ack in
            guard let connection = data.first as? JSONDictionary else { return }
            let meshConnection = ConnectionResponse.create((connection["connections"] as! JSONArray).first!)
            let realm = RealmUtilities.realm()
            try! realm.write { realm.add(meshConnection, update: true) }
            UserResponse.connections.append(meshConnection)
            DefaultNotification.post(name: .connection, object: meshConnection)
            
            let alert = TopAlert(title: "New Match", content: "You and \(meshConnection.user!.first_name!) are now connected!", imageURL: meshConnection.user!.photos!.large!, duration: 5)
            alert.actions = [AlertAction(title: "View Profile", icon: #imageLiteral(resourceName: "mainNavSettings"), handler: {
                let tab = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController
                tab?.presentedViewController?.dismiss()
                tab?.selectedIndex = 1
                alert.dismiss()
            }), AlertAction(title: "Send A Message", icon: #imageLiteral(resourceName: "mainNavConnections"), handler: { alert.dismiss() })]
            alert.presentIn(UIApplication.shared.delegate!.window!)
        }
        
        shared.socket.on("alive") { data, ack in }
        shared.socket.on("error") { data, ack in print(data) }
        shared.socket.on("disconnect") { data, ack in print(data) }
        
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
