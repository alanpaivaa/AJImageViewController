//
//  AJFadeTransition.swift
//  AJImageViewController
//
//  Created by Alan Jeferson on 24/08/15.
//  Copyright (c) 2015 AJWorks. All rights reserved.
//

import UIKit

class AJFadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: NSTimeInterval = 0.4
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        
        if let destinationViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            destinationViewController.view.alpha = 0.0
            destinationViewController.view.frame.origin.x = 0.0
            destinationViewController.view.frame.origin.y = 0.0
            containerView.addSubview(destinationViewController.view)
            UIView.animateWithDuration(self.duration, animations: { () -> Void in
                destinationViewController.view.alpha = 1.0
            }, completion: { (_) -> Void in
                transitionContext.completeTransition(true)
            })
        }
        
    }
    
    
}
