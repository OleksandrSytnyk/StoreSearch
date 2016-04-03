//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/31/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    var searchResults = [SearchResult]()
    private var firstTime = true
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    deinit {
    print("deinit \(self)")// to check if the controller is actually disposed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true//That allows you to position and size the view manually by changing its frame property.
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)//By setting this image as a pattern image on the background you get a repeatable image that fills the whole screen.
        pageControl.numberOfPages = 0//This effectively hides the page control, which is what you want to do when there are no search results (yet).
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
            
    super.viewWillLayoutSubviews()
            
    scrollView.frame = view.bounds
    pageControl.frame = CGRect( x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
        
        if firstTime {
        firstTime = false
        tileButtons(searchResults)
        }
    }
     
    private func tileButtons(searchResults: [SearchResult]) {
        
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
            
    case 568:
        columnsPerPage = 6
        itemWidth = 94
        marginX = 2
            
    case 667:
        columnsPerPage = 7
        itemWidth = 95
        itemHeight = 98
        marginX = 1
        marginY = 29
            
    case 736:
    columnsPerPage = 8
    rowsPerPage = 4
    itemWidth = 92
            
    default:
        break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        var row = 0
        var column = 0
        var x = marginX
        for searchResult in searchResults {
           
            let button = UIButton(type: .Custom)
            downloadImageForSearchResult(searchResult, andPlaceOnButton: button)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"),
                forState: .Normal)
           
            button.frame = CGRect(
            x: x + paddingHorz,
            y: marginY + CGFloat(row)*itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
           
            scrollView.addSubview(button)
           
            ++row
            if row == rowsPerPage {
            row = 0; x += itemWidth; ++column
            if column == columnsPerPage {
            column = 0; x += marginX * 2
                }
            }
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize( width: CGFloat(numPages)*scrollViewWidth,
        height: scrollView.bounds.size.height)
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages//This sets the number of dots that the page control displays to the number of pages that you calculated.
        pageControl.currentPage = 0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func pageChanged(sender: UIPageControl) {
    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
        self.scrollView.contentOffset = CGPoint(
        x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        },
        completion: nil)
    }
    
    private func downloadImageForSearchResult(searchResult: SearchResult, andPlaceOnButton button: UIButton) {
        
        if let url = NSURL(string: searchResult.artworkURL60) {
        
        let session = NSURLSession.sharedSession()
        
        let downloadTask = session.downloadTaskWithURL(url) {
        [weak button] url, response, error in
        if error == nil, let url = url, data = NSData(contentsOfURL: url),  image = UIImage(data: data) {
        dispatch_async(dispatch_get_main_queue()) {
        if let button = button {
        button.setImage(image, forState: .Normal)
                    }
                }
            }
        }
        downloadTask.resume()
        }
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    let width = scrollView.bounds.size.width
    let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
    pageControl.currentPage = currentPage
    }
}
