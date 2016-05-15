//
//  DimmingPresentationController.swift
//  GoodsFinder
//
//  Created by MyMacbook on 3/26/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    override func shouldRemovePresentersView() -> Bool {
    return false//this tell UIKit to leave the SearchViewController visible.
    }
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds  //it makes frame as big as the containerView
        containerView!.insertSubview(dimmingView, atIndex: 0)//this inserts dimmingView behind everything else in this “container view” (because of 0)
        
        dimmingView.alpha = 0  //0 for the alpha value of the gradient view represents completely transparent and 1 does fully visible
        if let transitionCoordinator =
            presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
            self.dimmingView.alpha = 1 }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
                if let transitionCoordinator =
                presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.dimmingView.alpha = 0 }, completion: nil)
        }
    }    
}
