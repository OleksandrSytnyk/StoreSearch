//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/26/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    override func shouldRemovePresentersView() -> Bool {
    return false
    }
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds  //it makes frame as big as the containerView
        containerView!.insertSubview(dimmingView, atIndex: 0)//this inserts dimmingView behind everything else in this “container view” (because of 0)
        
    }
   }
