//
//  NSURLSessionExtension.swift
//  SwiftLinkPreview
//
//  Created by Leonardo Cardoso on 15/06/2016.
//  Copyright © 2016 leocardz.com. All rights reserved.
//
import Foundation

extension URLSession {
    
    // Synchronous request to get the real URL
    func synchronousDataTaskWithURL(_ url: URL) -> (Data?, URLResponse?, Error?) {
        
        var data: Data?, response: URLResponse?, error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
            }.resume()
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return (data, response, error)
    }
    
}
