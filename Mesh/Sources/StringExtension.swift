//
//  StringExtension.swift
//  SwiftLinkPreview
//
//  Created by Leonardo Cardoso on 09/06/2016.
//  Copyright © 2016 leocardz.com. All rights reserved.
//
import Foundation
import UIKit

extension String {

    var trim: String { return trimmingCharacters(in: .whitespacesAndNewlines) }
    
    var extendedTrim: String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ").trim        
    }
    
    var decoded: String {
        let encodedData = data(using: String.Encoding.utf8)!
        let attributedOptions: [String: AnyObject] =
            [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
             NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue as AnyObject]
        do {
            return try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil).string
        } catch { return self }
    }
    
    var tagsStripped: String {
        return deleteTagByPattern(Regex.rawTagPattern)
    }
    
    func deleteTagByPattern(_ pattern: String) -> String {
        return replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
    }
    
    func replace(_ search: String, with: String) -> String {
        return replacingOccurrences(of: search, with: with, options: .caseInsensitive)
    }
    
    func substring(_ start: Int, end: Int) -> String {
        return substring(with: Range(characters.index(startIndex, offsetBy: start) ..< characters.index(startIndex, offsetBy: end)))
    }
    
    func substring(_ range: NSRange) -> String {
        var end = range.location + range.length
        end = end > characters.count ? characters.count - 1 : end
        
        return substring(range.location, end: end)
    }
    
    func isValidURL() -> Bool {
        return Regex.test(self, regex: Regex.rawUrlPattern)
    }
    
    func isImage() -> Bool {
        return Regex.test(self, regex: Regex.imagePattern)
    }
    
}
