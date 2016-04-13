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
    weak var splitViewDetail: DetailViewController?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Search", comment: "Split-view master button")
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0,
            right: 0)//This tells the table view to add a 64-point margin at the top, made up of 20 points for the status bar and 44 points for the Search Bar and 44 points for Navigation bar.
        tableView.rowHeight = 80
        
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
        searchBar.becomeFirstResponder()
        }
        
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
                title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
                message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"),
                preferredStyle: .Alert)
                
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Error alert: action"), style: .Default, handler: nil)
                alert.addAction(action)
                
                presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
            if case .Results (let list) = search.state {//It's the special if case statement to look at a single case using instead of switch.
        let detailViewController = segue.destinationViewController as! DetailViewController
        let indexPath = sender as! NSIndexPath
        let searchResult = list[indexPath.row]
        detailViewController.searchResult = searchResult
        detailViewController.isPopUp = true
            }
        }
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
            
        let rect = UIScreen.mainScreen().bounds
        if (rect.width == 736 && rect.height == 414) || // portrait
            (rect.width == 414 && rect.height == 736) { // landscape 
        if presentedViewController != nil {
        dismissViewControllerAnimated(true, completion: nil)
            }
        } else if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            
        switch newCollection.verticalSizeClass {
            
        case .Compact:
            showLandscapeViewWithCoordinator(coordinator)
            
        case .Regular, .Unspecified:
                hideLandscapeViewWithCoordinator(coordinator)
            }
        }
    }
    
    func showLandscapeViewWithCoordinator(
    coordinator: UIViewControllerTransitionCoordinator) {
               
    //precondition(landscapeViewController == nil)
                
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
        if self.presentedViewController != nil {
        self.dismissViewControllerAnimated(true, completion: nil)
        }
         }, completion: { _ in
    controller.view.removeFromSuperview()
    controller.removeFromParentViewController()//to truly dispose of the view controller
        self.landscapeViewController = nil//to remove the last strong reference to the LandscapeViewController object
            })//You don’t remove the view and the controller until the animation is completely done.
        }
    }
    
    func hideMasterPane() {
        UIView.animateWithDuration(0.25, animations: {
        self.splitViewController!.preferredDisplayMode = .PrimaryHidden },//this hides the master pane
            completion: { _ in
        self.splitViewController!.preferredDisplayMode = .Automatic })//without this the master pane would stay hidden even in landscape
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }//- a method searchBarSearchButtonClicked() is invoked when the user taps the Search button on the keyboard
    
    func performSearch() {
        
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            
            search.performSearchForText(searchBar.text!, category: category, completion: { success in
            
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
                self.landscapeViewController?.searchResultsReceived()
            })
            tableView.reloadData()
            searchBar.resignFirstResponder()//This tells the UISearchBar that it should no longer listen to keyboard input. As a result, the keyboard will hide itself until you tap inside the search bar again.
        }
    }
        
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch search.state {
        case .NotSearchedYet:
            return 0
        case .Loading:
            return 1
        case .NoResults:
            return 1
        case .Results(let list):
            return list.count
            }
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                
                switch search.state {
    case .NotSearchedYet:
        fatalError("Should never get here")//numberOfRowsInSection returns 0 for .NotSearchedYet and no cells will ever be asked for. This case is because a switch must always be exhaustive
    case .Loading:
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
                
        let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                
        return cell
        
    case .NoResults:
        return tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
    case .Results(let list):
        
            let cell = tableView.dequeueReusableCellWithIdentifier(
                TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            
            cell.configureForSearchResult(searchResult)
            
            return cell
                }
            }
    }


extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
            if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .Compact {// the window’s root view controller is the UISplitViewController here. On the iPhone the horizontal size class is always Compact. On the iPad it is always Regular.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
        } else {
        
        if case .Results(let list) = search.state {
        splitViewDetail?.searchResult = list[indexPath.row]
                }
        
        if splitViewController!.displayMode != .AllVisible { hideMasterPane()
            }
        }
    }
    
    func tableView(tableView: UITableView,
        willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
            
            switch search.state {
            case .NotSearchedYet, .Loading, .NoResults:
                return nil
            case .Results://You don’t need to bind the results array because you’re not using it for anything.
                return indexPath
        }
    }
    
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
}