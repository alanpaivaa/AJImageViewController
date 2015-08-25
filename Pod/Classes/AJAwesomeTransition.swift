//
//  AJAwesomeTransition.swift
//  Pods
//
//  Created by Alan Jeferson on 25/08/15.
//
//

import UIKit

class AJAwesomeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: NSTimeInterval = 0.5
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
        
        if let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            
            var alphaView = UIView(frame: containerView.frame)
            alphaView.backgroundColor = toViewController.view.backgroundColor
            alphaView.alpha = 0.0
            containerView.addSubview(alphaView)
            
            imageView = UIImageView(frame: self.referenceImageView.frame)
            imageView.image = self.referenceImageView.image
            imageView.contentMode = self.referenceImageView.contentMode
            imageView.layer.cornerRadius = self.referenceImageView.layer.cornerRadius
            imageView.clipsToBounds = self.referenceImageView.clipsToBounds
            
            self.referenceImageView.hidden = true
            
            containerView.addSubview(imageView)
            
            var destinationPoint = toViewController.view.center
            
            self.factor = self.imageWidth / imageView.frame.size.width
            
            UIView.animateWithDuration(self.duration, delay: 0, usingSpringWithDamping: (self.shouldBounce ? self.kDumping : 1.0), initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                imageView.transform = CGAffineTransformMakeScale(self.factor, self.factor)
                imageView.center = destinationPoint
                alphaView.alpha = 1.0
                }) { (_) -> Void in
                    self.presenting = false
                    alphaView.removeFromSuperview()
                    imageView.removeFromSuperview()
                    toViewController.view.frame.origin = CGPoint(x: 0, y: 0)
                    containerView.addSubview(toViewController.view)
                    transitionContext.completeTransition(true)
            }
            
        }
        
    }
    
}
