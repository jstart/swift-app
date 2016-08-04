//
//  Loading.swift
//  Mesh
//
//  Created by Christopher Truman on 8/2/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import UIKit

struct ActivityStyle {
    
    enum Position {
        case center
    }
    var style : UIActivityIndicatorViewStyle
    var position : Position
}

struct Loading {
    var viewController : UIViewController
    var activityStyle : ActivityStyle
    
    private var activityView : UIActivityIndicatorView
    
    init(viewController : UIViewController, activityStyle : ActivityStyle) {
        self.viewController = viewController
        self.activityStyle = activityStyle
        self.activityView = UIActivityIndicatorView(
            activityIndicatorStyle: .gray)
    }

    func addLoadingView(){
        activityView.activityIndicatorViewStyle = activityStyle.style
        viewController.view.addSubview(activityView)
        viewController.view.centerXAnchor.constraint(equalTo: activityView.centerXAnchor).isActive = true
        viewController.view.centerYAnchor.constraint(equalTo: activityView.centerYAnchor).isActive = true
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        activityView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func start(){
        activityView.startAnimating()
    }
    
    func stop(){
        activityView.stopAnimating()
    }
}
