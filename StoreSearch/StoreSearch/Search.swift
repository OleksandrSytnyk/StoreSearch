//
//  Search.swift
//  StoreSearch
//
//  Created by MyMacbook on 4/3/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit
typealias SearchComplete = (Bool) -> Void //Here you’re declaring a type for your own closure, named SearchComplete, which returns no value (it is Void) and takes one parameter.
class Search {
    
    enum State {
        case NotSearchedYet  //this is also used for when there is an error
        case Loading
        case NoResults
        case Results([SearchResult]) //[SearchResult] is a so-called associated value
    }
    
    private(set) var state: State = .NotSearchedYet //private(set) means private for set, but public for get
    
    private var dataTask: NSURLSessionDataTask? = nil
    
    enum Category: Int {
        
        case All = 0  //0 here is what is called the raw value, i.e. associated value
        case Music = 1
        case Software = 2
        case EBooks = 3
        
        var entityName: String {
        switch self {
        case .All: return ""
        case .Music: return "musicTrack"
        case .Software: return "software"
        case .EBooks: return "ebook"
            }
        }
    }
    
    
    
    func performSearchForText(text: String, category: Category, completion: SearchComplete) {
        if !text.isEmpty {
        dataTask?.cancel()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            state = .Loading
        
            let url = urlWithSearchText(text, category: category)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error in  ////response holds the server’s response code and headers
                self.state = .NotSearchedYet
                var success = false
                if let error = error where error.code == -999 {
                return // Search was cancelled
                }
                if let httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200,
                let data = data, dictionary = self.parseJSON(data) {
                var searchResults = self.parseDictionary(dictionary)
                    
                if searchResults.isEmpty {
                self.state = .NoResults 
                } else { 
                searchResults.sortInPlace(<)
                self.state = .Results(searchResults) 
                    }
                success = true
                }
            
                dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(success)
                    }
                })//The code from the completion handler will be invoked when the data task has received the reply from the server.
            dataTask?.resume()//this starts the data task on a background thread
        }
    }
    
    
    func urlWithSearchText(searchText: String, category: Category) -> NSURL {
        
       let entityName = category.entityName
        
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