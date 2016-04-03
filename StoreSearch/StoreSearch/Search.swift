//
//  Search.swift
//  StoreSearch
//
//  Created by MyMacbook on 4/3/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import Foundation
typealias SearchComplete = (Bool) -> Void //Here you’re declaring a type for your own closure, named SearchComplete, which returns no value (it is Void) and takes one parameter.
class Search {
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    private var dataTask: NSURLSessionDataTask? = nil
    
    func performSearchForText(text: String, category: Int, completion: SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            isLoading = true
            hasSearched = true
            searchResults = [SearchResult]()//it's to remove results of the old search
            let url = urlWithSearchText(text, category: category)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error in  ////response holds the server’s response code and headers
                var success = false
                if let error = error where error.code == -999 {
                return // Search was cancelled
                }
                if let httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200,
                let data = data, dictionary = self.parseJSON(data) {
                self.searchResults = self.parseDictionary(dictionary)
                self.searchResults.sortInPlace(<)
                print("Success!")
                self.isLoading = false
                success = true
                }
                if !success {
                print("Failure! \(response)")
                self.hasSearched = false
                self.isLoading = false
                }
                 
                dispatch_async(dispatch_get_main_queue()) {
                completion(success)
                    }
                })//The code from the completion handler will be invoked when the data task has received the reply from the server.
            dataTask?.resume()//this starts the data task on a background thread
        }
    }
    
    
    func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        
        
        let entityName: String
        
        switch category {
            
        case 1: entityName = "musicTrack"
            
        case 2: entityName = "software"
            
        case 3: entityName = "ebook"
            
        default: entityName = ""
        }
        
        let escapedSearchText =
        searchText.stringByAddingPercentEncodingWithAllowedCharacters(
            NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlString = String(format:
            "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
        
        return url!
    }
    
    
    func parseJSON(data: NSData) -> [String: AnyObject]? {
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
        
        guard let array = dictionary["results"] as? [AnyObject]
            else {
                print("Expected 'results' array")
                return []
        }
        
        var searchResults = [SearchResult]()
        
        for resultDict in array {
            
            if let resultDict = resultDict as? [String: AnyObject] {
                
                var searchResult: SearchResult?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    
                    switch wrapperType {
                        
                    case "track":
                        searchResult = parseTrack(resultDict)
                        
                    case "audiobook":
                        searchResult = parseAudioBook(resultDict)
                        
                    case "software":
                        searchResult = parseSoftware(resultDict)
                        
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String where kind == "ebook" {
                    searchResult = parseEBook(resultDict)
                }
                
                if let result = searchResult {
                    searchResults.append(result)
                    
                }
            }
        }
        return searchResults
    }
    
    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        
        if let genres: AnyObject = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        
        return searchResult
    }
    
}