//
//  FeedViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import Alamofire

/*struct MediumRequest : Request {
    let path = "browse/top?format=json"
    
    let method : HTTPMethod = .get
}*/

class FeedViewController: UIViewController {

    let cardStack = CardStack()
    let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(cardStack)
        view.addSubview(cardStack.view)
        
        cardStack.view.constrain(.height, .width, .centerX, .centerY, toItem: view)
        cardStack.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sorting"), style: .plain, target: self, action: #selector(sort))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "qrCode"), style: .plain, target: self, action: #selector(qr))
        
        let client = Client()
        /*client.execute(ProfileRequest(first_name: "john", last_name: "doe", email: "whatever@gmail.com", title: "lead product", profession: "software engineer", companies: [CompanyModel(id: "tinder", start_month: "January", start_year: "2014", end_month: "March", end_year: "2016", current: false)]), completionHandler: { response in
            print("JSON: \(response.result.value)")
            print(response.result.error)
        })*/
        
        let recs = {
            client.execute(RecommendationsRequest(), completionHandler: { response in
                guard let JSON = response.result.value else { return }
                print("JSON: \(JSON)")
                guard let jsonArray = JSON as? JSONArray else { return }
                let array = jsonArray.map({return UserResponse(JSON: $0)})
                self.cardStack.cards = array.map({
                    let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
                    return Card(type: .person, person: Person(user: $0, details: details))
                })
                self.cardStack.cards?.append(Card(type: .tweet, person: nil))
                print(response.result.error)
                if TARGET_OS_SIMULATOR == 1 {
                    client.execute(PositionRequest(lat: 33.978359, lon: -118.368723), completionHandler: { response in
                        guard let JSON = response.result.value as? JSONDictionary else {
                            print(response.result.error)
                            return
                        }
                        UserResponse.currentUser = UserResponse(JSON: JSON)
                         print("JSON: \(response.result.value)")
                         print(response.result.error)
                    })
                }
            })
        }
        client.execute(UpdatesRequest(last_update: Int(Date().timeIntervalSince1970)), completionHandler: { response in
            print("JSON: \(response.result.value)")
            guard let json = response.result.value as? JSONDictionary else { return }
            guard let connections = json["connections"] as? JSONDictionary else { return }
            guard let connectionsInner = connections["connections"] as? JSONArray else { return }
            UserResponse.connections = connectionsInner.map({return UserResponse(JSON: $0)}).sorted(by: {return $0.first_name! < $1.first_name!})
            
            guard let messages = json["messages"] as? JSONDictionary else { return }
            guard let messagesInner = messages["messages"] as? JSONArray else { return }
            UserResponse.messages = messagesInner.map({return MessageResponse(JSON: $0)})
            print(response.result.error)
            recs()
        })

        locationManager.locationUpdate = { location in
            print(location)
            client.execute(PositionRequest(lat: location.coordinate.latitude, lon: location.coordinate.longitude), completionHandler: { response in
                guard let JSON = response.result.value as? JSONDictionary else {
                    print(response.result.error)
                    return
                }
                UserResponse.currentUser = UserResponse(JSON: JSON)
                print("JSON: \(response.result.value)")
            })
        }
       
        locationManager.startTracking()
        /*for index in 0..<cardStack.cards!.count {
            guard let recIds = cardStack.cards?[index].person?.user?._id else {return}
            client.execute(ConnectionRequest(recipient: recIds), completionHandler: { response in
                print("JSON: \(response.result.value)")
                print(response.result.error)
            })
        }*/
        
        /*let request = MediumRequest()
        Alamofire.request("https://medium.com/" + request.path, withMethod: request.method, encoding: .json)
            .responseString(completionHandler: { response in
                let json = response.result.value!.substring(from: response.result.value!.index(response.result.value!.startIndex, offsetBy: 16))
                print(json)
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments)
                    print(jsonObject)
                } catch {
                }
            })*/
    }
    
    func sort(){
        
    }
    
    func qr() {
        if CameraManager.authStatus() == .authorized {
            self.present(ScanViewController().withNav(), animated: true, completion: nil)
            return
        }
        let alert = AlertViewController([AlertAction(title: "OKAY", backgroundColor: AlertAction.defaultBackground, titleColor: .white, handler: {
            self.dismiss(animated: true, completion: {
                CameraManager.requestAccess(completionHandler: { access in
                    if access {
                        self.present(ScanViewController().withNav(), animated: true, completion: nil)
                    }
                })
            })
        })], image: #imageLiteral(resourceName: "enableCameraAccess"))
        alert.titleLabel.text = "Camera Access"
        alert.textLabel.text = "We need access to your camera in order to use this feature and scan codes"
        alert.modalPresentationStyle = .overCurrentContext
        present(alert, animated: true, completion: nil)
    }
}
