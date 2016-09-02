//
//  SwiftLinkPreview.swift
//  SwiftLinkPreview
//
//  Created by Leonardo Cardoso on 09/06/2016.
//  Copyright © 2016 leocardz.com. All rights reserved.
//
import Foundation

open class SwiftLinkPreview {
    
    // MARK: - Vars
    static let titleMinimumRelevant: Int = 15
    static let decriptionMinimumRelevant: Int = 100
    fileprivate var url: URL!
    var task: URLSessionDataTask?
    fileprivate let session = URLSession(configuration: URLSessionConfiguration.default.then {
        let additionalHeadersDict = ["User-Agent" : "'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)')"]
        $0.httpAdditionalHeaders = additionalHeadersDict
    })
    internal var text: String!
    internal var result: [String: String] = [:]
    
    // MARK: - Functions
    open func preview(_ previewText: String!, onSuccess: @escaping ([String: Any]) -> (), onError: @escaping (PreviewError) -> ()) {
        resetResult()
        text = previewText
        
        guard let url = extractURL() else {
            onError(PreviewError(type: .NoURLHasBeenFound, url: self.text))
            return
        }
        self.url = url
        result["url"] = self.url.absoluteString
        self.extractInfo({
            onSuccess(self.result)
            }, onError: onError)
    }
    
    // Reset data on result
    internal func resetResult() {
        result = ["url": "" ,
                  "finalUrl": "",
                  "canonicalUrl": "",
                  "title": "",
                  "description": "",
                  "image": ""]
    }
    
    // Fill remaining info about the crawling
    fileprivate func fillRemainingInfo(_ title: String, description: String, image: String) {
        result["title"] = title
        result["description"] = description
        result["image"] = image
    }
}

// Extraction functions
extension SwiftLinkPreview {
    
    // Extract first URL from text
    internal func extractURL() -> URL? {
        
        let explosion = self.text.characters.split{$0 == " "}.map(String.init)
        let pieces = explosion.filter({ $0.trim.isValidURL() })
        var piece = pieces[0]
        piece = piece.replace("http://", with: "https://")
        guard let url = URL(string: piece) else { return nil }
        return url
    }
    
    // Extract HTML code and the information contained on it
    fileprivate func extractInfo(_ completion: @escaping () -> (), onError: @escaping (PreviewError) -> ()) {
        guard let url = URL(string: result["url"]!) else {
            fillRemainingInfo("", description: "", image: "")
            completion()
            return
        }
        if (url.absoluteString.isImage()) {
            fillRemainingInfo("", description: "", image: url.absoluteString)
            completion()
            return
        }
        
        task = session.dataTask(with: url, completionHandler: { data, response, error in
            guard error == nil else {
                onError(PreviewError(type: .NoURLHasBeenFound, url: response?.url?.absoluteString ?? ""))
                return
            }
            self.result["finalUrl"] = response?.url?.absoluteString ?? ""
            self.result["canonicalUrl"] = response?.url?.host ?? ""
            
            // Try to get the page with its default enconding
            var source = String(data: data!, encoding: String.Encoding.utf8)!.extendedTrim
            
            source = self.cleanSource(source)
            self.performPageCrawling(source)
            DispatchQueue.main.async {
                completion()
            }
        })
        task?.resume()
    }
    
    // Removing unnecessary data from the source
    fileprivate func cleanSource(_ source: String) -> String {
        var source = source
        source = source.deleteTagByPattern(Regex.inlineStylePattern)
        source = source.deleteTagByPattern(Regex.inlineScriptPattern)
        source = source.deleteTagByPattern(Regex.linkPattern)
        source = source.deleteTagByPattern(Regex.scriptPattern)
        source = source.deleteTagByPattern(Regex.commentPattern)
        
        return source
    }
    
    fileprivate func performPageCrawling(_ htmlCode: String) {
        var htmlCode = htmlCode
        crawlMetaTags(htmlCode)
        htmlCode = crawlTitle(htmlCode)
        htmlCode = crawlDescription(htmlCode)
    }
}

// Tag functions
extension SwiftLinkPreview {
    
    // Search for meta tags
    internal func crawlMetaTags(_ htmlCode: String) {
        
        let possibleTags = ["title", "description", "image"]
        let metatags = Regex.pregMatchAll(htmlCode, regex: Regex.metatagPattern, index: 1)
        
        for metatag in metatags {
            
            for tag in possibleTags {
                
                if (metatag.range(of: "property=\"og:\(tag)") != nil ||
                    metatag.range(of: "property='og:\(tag)") != nil ||
                    metatag.range(of: "name=\"twitter:\(tag)") != nil ||
                    metatag.range(of: "name='twitter:\(tag)") != nil ||
                    metatag.range(of: "name=\"\(tag)") != nil ||
                    metatag.range(of: "name='\(tag)") != nil ||
                    metatag.range(of: "itemprop=\"\(tag)") != nil ||
                    metatag.range(of: "itemprop='\(tag)") != nil) {
                    
                    if (result[tag]!.isEmpty) {
                        
                        if let value = Regex.pregMatchFirst(metatag, regex: Regex.metatagContentPattern, index: 2) {
                            
                            let value = value.decoded.extendedTrim
                            result[tag] = tag == "image" ? addImagePrefixIfNeeded(value) : value
                        }
                    }
                }
            }
        }
    }
    
    // Crawl for title if needed
    internal func crawlTitle(_ htmlCode: String) -> String {
        
        if let title: String = result["title"] {
            
            if title.isEmpty {
                
                if let value = Regex.pregMatchFirst(htmlCode, regex: Regex.titlePattern, index: 2) {
                    
                    if value.isEmpty {
                        
                        let fromBody: String = crawlCode(htmlCode, minimum: SwiftLinkPreview.titleMinimumRelevant)
                        if !fromBody.isEmpty {
                            
                            self.result["title"] = fromBody.decoded.extendedTrim
                            
                            return htmlCode.replace(fromBody, with: "")
                        }
                        
                    } else {
                        
                        self.result["title"] = value.decoded.extendedTrim
                    }
                }
            }
        }
        
        return htmlCode
        
    }
    
    // Crawl for description if needed
    internal func crawlDescription(_ htmlCode: String) -> String {
        
        if let description: String = self.result["description"] {
            
            if description.isEmpty {
                
                let value: String = crawlCode(htmlCode, minimum: SwiftLinkPreview.decriptionMinimumRelevant)
                    
                self.result["description"] = value.decoded.extendedTrim
            }
            
        }
        
        return htmlCode
        
    }
    
    // Add prefix image if needed
    fileprivate func addImagePrefixIfNeeded(_ image: String) -> String {
        
        var image = image
        
        if let canonicalUrl: String = self.result["canonicalUrl"] {
            
            if image.hasPrefix("//") {
                
                image = "http:" + image
                
            } else if image.hasPrefix("/") {
                
                image = "http://" + canonicalUrl + image
                
            }
            
        }
        
        return image
        
    }
    
    // Crawl the entire code
    internal func crawlCode(_ content: String, minimum: Int) -> String {
        
        let resultFirstSearch = self.getTagContent("p", content: content, minimum: minimum)
        
        if (!resultFirstSearch.isEmpty) {
            
            return resultFirstSearch
            
        } else {
            
            let resultSecondSearch = self.getTagContent("div", content: content, minimum: minimum)
            
            if (!resultSecondSearch.isEmpty) {
                
                return resultSecondSearch
                
            } else {
                
                let resultThirdSearch = self.getTagContent("span", content: content, minimum: minimum)
                
                if (!resultThirdSearch.isEmpty) {
                    
                    return resultThirdSearch
                    
                } else {
                    
                    if (resultThirdSearch.characters.count >= resultFirstSearch.characters.count) {
                        
                        if (resultThirdSearch.characters.count >= resultThirdSearch.characters.count) {
                            
                            return resultThirdSearch
                            
                        } else {
                            
                            return resultThirdSearch
                            
                        }
                        
                    } else {
                        
                        return resultFirstSearch
                        
                    }
                    
                }

            }
            
        }
        
    }
    
    // Get tag content
    fileprivate func getTagContent(_ tag: String, content: String, minimum: Int) -> String {
        let pattern = Regex.tagPattern(tag)
        
        let index = 2
        let rawMatches = Regex.pregMatchAll(content, regex: pattern, index: index)
        
        let matches = rawMatches.filter({ $0.extendedTrim.tagsStripped.characters.count >= minimum })
        var result = matches.count > 0 ? matches[0] : ""
        
        if result.isEmpty {
            if let match = Regex.pregMatchFirst(content, regex: pattern, index: 2) {
                result = match.extendedTrim.tagsStripped
            }
            
        }
        return result
    }
    
}
