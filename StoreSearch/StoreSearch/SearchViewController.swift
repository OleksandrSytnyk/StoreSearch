//
//  ViewController.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/12/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0,
            right: 0)//This tells the table view to add a 64-point margin at the top, made up of 20 points for the status bar and 44 points for the Search Bar. 
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib,
            forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        tableView.rowHeight = 80
        
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    func urlWithSearchText(searchText: String) -> NSURL {
         
        let escapedSearchText =
        searchText.stringByAddingPercentEncodingWithAllowedCharacters(  
            NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlString = String(format:
        "https://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = NSURL(string: urlString)
        
        return url!
    }
    
    func performStoreRequestWithURL(url: NSURL) -> String? {
            do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download Error: \(error)")
            return nil
            }
    }
    
    func parseJSON(jsonString: String) -> [String: AnyObject]? {
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        else { return nil }
        
        do {
        return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
        print("JSON Error: \(error)")
        return nil
        }
    }
    
    func showNetworkError() {
                let alert = UIAlertController(
                title: "Whoops...",
                message:
                "There was an error reading from the iTunes Store. Please try again.",
                preferredStyle: .Alert)
                
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(action)
                
                presentViewController(alert, animated: true, completion: nil)
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
            
        default:
            break
            }
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

}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
    if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()//This tells the UISearchBar that it should no longer listen to keyboard input. As a result, the keyboard will hide itself until you tap inside the search bar again.
        searchResults = [SearchResult]()//it's to remove results of the old search
        hasSearched = true
        
        let url = urlWithSearchText(searchBar.text!)
        print("URL: '\(url)'")
        if let jsonString = performStoreRequestWithURL(url) {
            if let dictionary = parseJSON(jsonString) {
            print("Dictionary \(dictionary)")
        
       searchResults = parseDictionary(dictionary)
        tableView.reloadData()
        return
            }
        }
            showNetworkError()
        
    }
    }//- a method searchBarSearchButtonClicked() is invoked when the user taps the Search button on the keyboard
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if !hasSearched {
                return 0
            }
            else if searchResults.count == 0 {
            return 1
            } else {
            return searchResults.count
            }
        }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         
        
        if searchResults.count == 0 {
        /*cell.nameLabel.text = "(Nothing found)"
        cell.artistNameLabel.text = ""   this is to fix a bug whih I missed in the previous commit*/
            return tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row] 
        cell.nameLabel.text = searchResult.name
        cell.artistNameLabel.text = searchResult.artistName//You no longer need to write ! to unwrap because the outlets are implicitly unwrapped optionals, not true optionals.
            
            return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView,
        willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 { return nil
    } else {
        return indexPath
        }
    }
    
}