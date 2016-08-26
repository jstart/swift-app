//
//  FeedViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

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
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    guard let jsonArray = JSON as? [[String : Any]] else { return }
                    let array = jsonArray.map({return UserResponse(JSON: $0)})
                    self.cardStack.cards = array.map({
                        let details = UserDetails(connections: [], experiences: [], educationItems: [], skills: [], events: [])
                        return Card(type: .person, person: Person(user: $0, details: details))
                    })
                }
                print(response.result.error)
            })
        }
        client.execute(UpdatesRequest(last_update: Int(Date().timeIntervalSince1970)), completionHandler: { response in
            print("JSON: \(response.result.value)")
            print(response.result.error)
            recs()
        })

        locationManager.locationUpdate = { location in
            print(location)
            client.execute(PositionRequest(lat: location.coordinate.latitude, lon: location.coordinate.longitude), completionHandler: { response in
                    print("JSON: \(response.result.value)")
                    print(response.result.error)
            })
        }
        if TARGET_OS_SIMULATOR == 1 {
            /*client.execute(PositionRequest(lat: 33.978359, lon: -118.368723), completionHandler: { response in
                print("JSON: \(response.result.value)")
                print(response.result.error)
            })*/
        }
        
        self.locationManager.startTracking()
    }

    func sort(){
        
    }
    
    func qr() {
        
        present(ScanViewController().withNav(), animated: true, completion: nil)
    }
}
