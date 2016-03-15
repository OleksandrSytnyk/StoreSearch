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
        let cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "SearchResultCell")
        tableView.rowHeight = 80
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()//This tells the UISearchBar that it should no longer listen to keyboard input. As a result, the keyboard will hide itself until you tap inside the search bar again.
        searchResults = [SearchResult]()//it's to remove results of the old search
        hasSearched = true
        
        if searchBar.text! != "justin bieber" {
        for i in 0...2 {
            let searchResult = SearchResult()
            searchResult.name = String(format: "Fake Result %d for", i)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
            }
        }

        tableView.reloadData()
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
         
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "SearchResultCell", forIndexPath: indexPath) as! SearchResultCell
        if searchResults.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
        let searchResult = searchResults[indexPath.row] 
        cell.nameLabel.text = searchResult.name
        cell.artistNameLabel.text = searchResult.artistName//You no longer need to write ! to unwrap because the outlets are implicitly unwrapped optionals, not true optionals.
        }
        
        return cell
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