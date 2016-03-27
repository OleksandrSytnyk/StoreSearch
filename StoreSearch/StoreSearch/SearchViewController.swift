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
    var isLoading = false
    var dataTask: NSURLSessionDataTask?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0,
            right: 0)//This tells the table view to add a 64-point margin at the top, made up of 20 points for the status bar and 44 points for the Search Bar and 44 points for Navigation bar.
        tableView.rowHeight = 80
        searchBar.becomeFirstResponder()
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib,
            forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segmentChanged(sender: UISegmentedControl) {
       performSearch()
    }

    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
        let detailViewController = segue.destinationViewController as! DetailViewController
        let indexPath = sender as! NSIndexPath
        let searchResult = searchResults[indexPath.row]
        detailViewController.searchResult = searchResult
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
    
    if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()//This tells the UISearchBar that it should no longer listen to keyboard input. As a result, the keyboard will hide itself until you tap inside the search bar again.
        
        dataTask?.cancel()
        
        isLoading = true
        tableView.reloadData()
        
       searchResults = [SearchResult]()//it's to remove results of the old search
        hasSearched = true

        let url = urlWithSearchText(searchBar.text!, category: segmentedControl.selectedSegmentIndex)
       
        let session = NSURLSession.sharedSession()
        
        dataTask = session.dataTaskWithURL(url, completionHandler: { data, response, error in
        //response holds the server’s response code and headers
            print("On the main thread? " + (NSThread.currentThread().isMainThread ? "Yes" : "No"))
            if let error = error where error.code == -999  {
            return
        } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                if let data = data, dictionary = self.parseJSON(data) {
                    self.searchResults = self.parseDictionary(dictionary)
                    self.searchResults.sortInPlace(<)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
        } else {
            print("Failure! \(response!)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
            self.hasSearched = false
            self.isLoading = false
            self.tableView.reloadData()
            self.showNetworkError()
            }
            
        })//The code from the completion handler will be invoked when the data task has received the reply from the server.
        
        dataTask?.resume()//this starts the data task on a background thread
        }
    }//- a method searchBarSearchButtonClicked() is invoked when the user taps the Search button on the keyboard
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 1
        } else if !hasSearched {
                return 0
            }
            else if searchResults.count == 0 {
            return 1
            } else {
            return searchResults.count
            }
        }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
            
        } else if searchResults.count == 0 {
        /*cell.nameLabel.text = "(Nothing found)"
        cell.artistNameLabel.text = ""   this is to fix a bug whih I missed in the previous commit*/
            return tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row] 
       
        cell.configureForSearchResult(searchResult)
                    
        return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView,
        willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 || isLoading{
            return nil
    } else {
        return indexPath
        }
    }
    
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
}