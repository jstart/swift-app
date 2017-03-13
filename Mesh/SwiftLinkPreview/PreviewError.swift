//
//  PreviewError.swift
//  SwiftLinkPreview
//
//  Created by Leonardo Cardoso on 09/06/2016.
//  Copyright © 2016 leocardz.com. All rights reserved.
//
import Foundation

// MARK: - Error enum
open class PreviewError {
    
    open var message: String?
    open var type: PreviewErrorType?
    
    public init(type: PreviewErrorType, url: URL) {
        self.type = type
        self.message = type.rawValue + ": \"\(url.absoluteString)\""
    }
    
    public init(type: PreviewErrorType, url: String) {
        self.type = type
        self.message = type.rawValue + ": \"\(url)\""
    }
    
}
