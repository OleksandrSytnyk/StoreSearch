//
//  ViewController.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/12/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    let search = Search()
    var landscapeViewController: LandscapeViewController?
    
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
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
        let detailViewController = segue.destinationViewController as! DetailViewController
        let indexPath = sender as! NSIndexPath
        let searchResult = search.searchResults[indexPath.row]
        detailViewController.searchResult = searchResult
        }
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        switch newCollection.verticalSizeClass {
            
        case .Compact:
            showLandscapeViewWithCoordinator(coordinator)
            
        case .Regular, .Unspecified:
                hideLandscapeViewWithCoordinator(coordinator)
        }
    }
    
    func showLandscapeViewWithCoordinator(
    coordinator: UIViewControllerTransitionCoordinator) {
               
    precondition(landscapeViewController == nil)
                
    landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier( "LandscapeViewController") as? LandscapeViewController
                
    if let controller = landscapeViewController {
        
    controller.search = search
    controller.view.frame = view.bounds
    controller.view.alpha = 0
               
    view.addSubview(controller.view)//This places controller.view on top of the SearchResult controller's view
    addChildViewController(controller)//this tell the SearchViewController  that controller is who is managing it's part of the screen, actually full top of the screen
    coordinator.animateAlongsideTransition({ _ in
             
    controller.view.alpha = 1
    self.searchBar.resignFirstResponder()
        
    if self.presentedViewController != nil {
    self.dismissViewControllerAnimated(true, completion: nil)//to dismiss pop-up
        }
    }, completion: { _ in
    controller.didMoveToParentViewController(self) //this tell controller that it has a parent
        //you put this here to delay the call to didMoveToParentViewController() until the animation is over.
            })//Both closures are given a “transition coordinator context” parameter (the same context that animation controllers get) but it’s not very interesting here and you use the _ wildcard to ignore it.
        }
    }
    
    func hideLandscapeViewWithCoordinator(
    coordinator: UIViewControllerTransitionCoordinator) {
                    
    if let controller = landscapeViewController {
    controller.willMoveToParentViewController(nil)//this tells controller that it no longer has a parent
        
    coordinator.animateAlongsideTransition({ _ in 
        controller.view.alpha = 0
         }, completion: { _ in
    controller.view.removeFromSuperview()
    controller.removeFromParentViewController()//to truly dispose of the view controller
        self.landscapeViewController = nil//to remove the last strong reference to the LandscapeViewController object
            })//You don’t remove the view and the controller until the animation is completely done.
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }//- a method searchBarSearchButtonClicked() is invoked when the user taps the Search button on the keyboard
    
    func performSearch() {
        
        search.performSearchForText(searchBar.text!, category: segmentedControl.selectedSegmentIndex, completion: { success in
            
            if !success {
            self.showNetworkError()
            }
            self.tableView.reloadData()
            })
    //tableView.reloadData()
    searchBar.resignFirstResponder()//This tells the UISearchBar that it should no longer listen to keyboard input. As a result, the keyboard will hide itself until you tap inside the search bar again.
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if search.isLoading {
            return 1
        } else if !search.hasSearched {
                return 0
            }
            else if search.searchResults.count == 0 {
            return 1
            } else {
            return search.searchResults.count
            }
        }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if search.isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
            
        } else if search.searchResults.count == 0 {
        /*cell.nameLabel.text = "(Nothing found)"
        cell.artistNameLabel.text = ""   this is to fix a bug whih I missed in the previous commit*/
            return tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        let searchResult = search.searchResults[indexPath.row] 
       
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
        if search.searchResults.count == 0 || search.isLoading{
            return nil
    } else {
        return indexPath
        }
    }
    
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
}