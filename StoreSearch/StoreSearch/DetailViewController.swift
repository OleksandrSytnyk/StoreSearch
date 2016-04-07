//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/26/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var searchResult: SearchResult!
    var downloadTask: NSURLSessionDownloadTask?
    
    enum AnimationStyle {
        case Slide
        case Fade
    }
    var dismissAnimationStyle = AnimationStyle.Fade
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }

    override func viewDidLoad() {
    super.viewDidLoad()
    view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    popupView.layer.cornerRadius = 10
    view.backgroundColor = UIColor.clearColor()
            
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self
    view.addGestureRecognizer(gestureRecognizer)//This creates the new gesture recognizer that listens to taps anywhere in this view controller and calls the close() method in response.
        
        if searchResult != nil {
            updateUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func close() {
    dismissAnimationStyle = .Slide
    dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func updateUI() {
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
        artistNameLabel.text = NSLocalizedString("Unknown", comment: "Localized kind: Unknown artist Name for DetailView")
        } else {
        artistNameLabel.text = searchResult.artistName
        }
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        
        if searchResult.price == 0 {
            priceText = NSLocalizedString("Free", comment: "Localized kind:   price for free for DetailView")
        } else if let text = formatter.stringFromNumber(searchResult.price) {
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, forState: .Normal)
        
        if let url = NSURL(string: searchResult.artworkURL100) {
                downloadTask = artworkImageView.loadImageWithURL(url)
        }
         
    }
    
    @IBAction func openInStore() {
    if let url = NSURL(string: searchResult.storeURL) {
    UIApplication.sharedApplication().openURL(url)
            }
    }
                             
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(
        presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController( presentedViewController: presented,
        presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController( presented: UIViewController,
        presentingController presenting: UIViewController, sourceController source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        
        return BounceAnimationController()
    }
    
    func animationControllerForDismissedController( dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        switch dismissAnimationStyle {
    case .Slide:
        return SlideOutAnimationController()
    case .Fade:
        return FadeOutAnimationController() }
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
    shouldReceiveTouch touch: UITouch) -> Bool {
        
    return (touch.view === self.view)
    }
}
