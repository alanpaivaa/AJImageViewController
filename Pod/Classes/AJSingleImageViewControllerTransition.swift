//
//  AJImageViewControllerTransition.swift
//  AJImageViewController
//
//  Created by Alan Jeferson on 22/08/15.
//  Copyright (c) 2015 AJWorks. All rights reserved.
//

import UIKit

class AJSingleImageViewControllerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: NSTimeInterval = 0.6
    var presenting = true
    var originFrame = CGRect.zeroRect
    var referenceImageView: UIImageView!
    var factor: CGFloat!
    var imageWidth: CGFloat!
    var shouldBounce: Bool = true
    private let kDumping: CGFloat = 0.8
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        var imageView: UIImageView!
        var destinationPoint: CGPoint!
        
        if let singleImageController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? AJSingleImageViewController {
            imageView = singleImageController.imageView
        } else {
            destinationPoint = self.referenceImageView.center
            imageView = self.referenceImageView
            imageView.transform = CGAffineTransformMakeScale(self.factor, self.factor)
        }
        
        if let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            
            if !self.presenting {
                imageView.center = toViewController.view.center
            } else {
                destinationPoint = toViewController.view.center
            }
            
            toViewController.view.frame.origin = CGPoint(x: 0, y: 0)
            let color = toViewController.view.backgroundColor
            toViewController.view.backgroundColor = fromViewController.view.backgroundColor
            containerView.addSubview(toViewController.view)
            
            self.factor = self.imageWidth / imageView.frame.size.width
            
            UIView.animateWithDuration(self.duration, delay: 0, usingSpringWithDamping: (self.shouldBounce ? self.kDumping : 1.0), initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                imageView.transform = CGAffineTransformMakeScale(self.factor, self.factor)
                imageView.center = destinationPoint
                toViewController.view.backgroundColor = color
                }) { (_) -> Void in
                    self.presenting = false
                    transitionContext.completeTransition(true)
            }
            
        }
        
    }
    
}
