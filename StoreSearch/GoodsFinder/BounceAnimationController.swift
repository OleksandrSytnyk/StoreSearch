//
//  BounceAnimationController.swift
//  GoodsFinder
//
//  Created by MyMacbook on 3/29/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {//this is an animator object
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4  //it's 0.4 sec
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
    if let toViewController = transitionContext.viewControllerForKey( UITransitionContextToViewControllerKey),
       let toView = transitionContext.viewForKey( UITransitionContextToViewKey),
       let containerView = transitionContext.containerView() {
        
        toView.frame = transitionContext.finalFrameForViewController(toViewController)
        containerView.addSubview(toView)
        toView.transform = CGAffineTransformMakeScale(0.7, 0.7)
    UIView.animateKeyframesWithDuration( transitionDuration(transitionContext), delay: 0,
    options: .CalculationModeCubic, animations: {

        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.334,  animations: {
        toView.transform = CGAffineTransformMakeScale(1.2, 1.2)
        toView.transform = CGAffineTransformMakeRotation(0.005)
        })//The time 0.334 is not in seconds but in fractions of the animation’s total duration (0.4 seconds).
        
        
        UIView.addKeyframeWithRelativeStartTime(0.334, relativeDuration: 0.333, animations: {
        toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            toView.transform = CGAffineTransformMakeRotation(-0.005)
            })
        
        UIView.addKeyframeWithRelativeStartTime(0.666, relativeDuration: 0.333, animations: {toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            toView.transform = CGAffineTransformMakeRotation(0)
        })
        
        }, completion: {
        finished in transitionContext.completeTransition(finished)
        })
        }
    }
}