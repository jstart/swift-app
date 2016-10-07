//
//  EventCardViewController.swift
//  Mesh
//
//  Created by Christopher Truman on 8/4/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit
import SafariServices

class EventCardViewController : BaseCardViewController {

    let name = UILabel().then {
        $0.textColor = .darkGray; $0.font = .boldProxima(ofSize: 20)
        $0.text = "Google I/O 2016"
    }
    let subtitle = UILabel().then {
        $0.textColor = .lightGray; $0.font = .proxima(ofSize: 12)
        $0.text = "Related to Tech and Java"
    }
    let media = UIImageView(translates: false).then {
        $0.image = #imageLiteral(resourceName: "eventHeader")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1; $0.layer.borderColor = UIColor.clear.cgColor
        $0.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
        $0.constrain(.height, relatedBy: .greaterThanOrEqual, constant: 80)
        $0.constrain(.height, relatedBy: .lessThanOrEqual, constant: 160)
    }
    let badge = UIImageView(translates: false).then {
        $0.image = #imageLiteral(resourceName: "EventBadge")
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
        $0.constrain((.height, 50), (.width, 50))
    }
    let text = UILabel(translates: false).then {
        $0.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1); $0.font = .proxima(ofSize: 14)
        $0.numberOfLines = 0
        $0.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed mollis lacinia volutpat. Sed a sollicitudin metus, nec accumsan metus sed iaculis."
    }
    let date = UILabel(translates: false).then {
        $0.textColor = .lightGray; $0.font = .proxima(ofSize: 14)
        $0.text = "Tomorrow at 8 AM"
    }
    let location = UILabel(translates: false).then {
        $0.textColor = .lightGray; $0.font = .proxima(ofSize: 14)
        $0.text = "The Venetian"
    }
    let address = UILabel(translates: false).then {
        $0.textColor = .lightGray; $0.font = .proxima(ofSize: 12)
        $0.text = "3355 S Las Vegas Blvd, Las Vegas, NV 89109"
    }
    let url = UILabel(translates: false).then {
        $0.textColor = .lightGray; $0.font = .proxima(ofSize: 14)
        $0.text = "www.googleio2016.com"
    }
    
    var descriptionStack : UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(media)
        media.constrain(.top, .leading, .trailing, toItem: view)
        
        let titleStack = UIStackView(name, subtitle, axis: .vertical)
        titleStack.distribution = .fillProportionally
        
        let headerStack = UIStackView(badge, titleStack, spacing: 20)
        headerStack.translates = false
        view.addSubview(headerStack)
        
        headerStack.constrain((.height, 60))
        headerStack.constrain(.top, constant: 10, toItem: media, toAttribute: .bottom)
        headerStack.constrain((.leading, 12), (.trailing, -12), toItem: view)
        
        var barView = bar()
        view.addSubview(barView)
        barView.constrain(.top, constant: 10, toItem: headerStack, toAttribute: .bottom)
        barView.constrain(.width, toItem: view)
        
        view.addSubview(text)
        text.constrain((.leading, 12), (.trailing, -12), toItem: view)
        text.constrain(.top, constant: 10, toItem: barView, toAttribute: .bottom)
        
        barView = bar()
        view.addSubview(barView)
        barView.constrain(.top, constant: 10, toItem: text, toAttribute: .bottom)
        barView.constrain(.width, toItem: view)
        
        let clock = UIImageView(image: #imageLiteral(resourceName: "clock"))
        clock.contentMode = .scaleAspectFit
        let location = UIImageView(image: #imageLiteral(resourceName: "location"))
        location.contentMode = .scaleAspectFit
        let url = UIImageView(image: #imageLiteral(resourceName: "location"))
        location.contentMode = .scaleAspectFit

        descriptionStack = UIStackView(UIStackView(clock, date, spacing: 10),
                                       UIStackView(location, UIStackView(self.location, address, axis: .vertical), spacing: 10),
                                       UIStackView(url, self.url, spacing: 10), axis: .vertical, spacing: 10)
        descriptionStack?.distribution = .fillProportionally
        descriptionStack?.alignment = .leading
        descriptionStack?.translates = false
        view.addSubview(descriptionStack!)
        descriptionStack?.constrain((.leading, 12), (.trailing, -12), toItem: view)
        descriptionStack?.constrain(.top, constant: 8, toItem: barView, toAttribute: .bottom)
        descriptionStack?.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)

        barView = bar()
        view.addSubview(barView)
        barView.constrain(.top, constant: 8, toItem: descriptionStack, toAttribute: .bottom)
        barView.constrain(.width, toItem: view)
        
        let connectionView = QuickViewGenerator.quickView(RealmUtilities.objects(ConnectionResponse.self))
        connectionView.translates = false
        connectionView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
        
        view.addSubview(connectionView)
        connectionView.constrain(.top, toItem: barView, toAttribute: .bottom)
        connectionView.constrain((.leading, 12), (.trailing, -12), toItem: view)
        connectionView.constrain(.bottom, constant: -10, toItem: view)
        
        configure()
    }
    
    func configure() {
        guard let event = rec?.event else { return }
        name.text = event.name
        text.text = event.descriptionText
        media.af_setImage(withURL: URL(string: event.logo)!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        media.round(corners: [.topLeft, .topRight])
    }
    
    func bar() -> UIView {
        return UIView(translates: false).then {
            $0.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            $0.constrain(.height, constant: 1)
        }
    }
    
    override func tap(_ sender: UITapGestureRecognizer) { navigationController?.safari("https://eventbrite.com", push: false) }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !otherGestureRecognizer.isMember(of: UITapGestureRecognizer.self)
    }
    
}
