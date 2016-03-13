//
//  ViewController.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/12/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0,
            right: 0)//This tells the table view to add a 64-point margin at the top, made up of 20 points for the status bar and 44 points for the Search Bar. 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    print("The search text is: '\(searchBar.text!)'")
    }//- a method searchBarSearchButtonClicked() is invoked when the user taps the Search button on the keyboard
}

extension SearchViewController: UITableViewDataSource {
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
        }
}

extension SearchViewController: UITableViewDelegate {
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
}