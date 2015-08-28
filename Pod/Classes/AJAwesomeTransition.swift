//
//  AJAwesomeTransition.swift
//  Pods
//
//  Created by Alan Jeferson on 25/08/15.
//
//

import UIKit

class AJAwesomeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: NSTimeInterval = 0.6
    private let kDumping: CGFloat = 0.8
    private var originalImageView: UIImageView!
    var presenting = true
    var referenceImageView: UIImageView!
    var imageWidth: CGFloat!
    var shouldBounce: Bool = true
    var shouldRotate: Bool = false
    private var destinationPoint: CGPoint!
    private var originalImageCenter: CGPoint!
    var dismissalType = AJImageViewDismissalType.OriginalImage
    var rotation: CGFloat?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        
        //Setups the image view which holds the scale and move animations
        var imageView = UIImageView(frame: self.referenceImageView.frame)
        imageView.image = self.referenceImageView.image
        imageView.contentMode = self.referenceImageView.contentMode
        imageView.layer.cornerRadius = self.referenceImageView.layer.cornerRadius
        imageView.clipsToBounds = self.referenceImageView.clipsToBounds
        
        //Keeps a reference to the image view from the first view controller
        self.originalImageView = self.originalImageView ?? self.referenceImageView
        
        //Factor to scale the animating image
        var factor = self.imageWidth / imageView.frame.size.width
        
        if let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            
            //Setting up destination point
            if let toViewController = toViewController as? AJImageViewController {
                self.originalImageCenter = self.referenceImageView.center
                self.destinationPoint = containerView.center
            } else {
                //If user did not chang page image after dismissing
                if self.dismissalType == AJImageViewDismissalType.OriginalImage {
                    self.destinationPoint = self.originalImageCenter
                } else {
                    //Otherwise
                    self.destinationPoint.x = self.referenceImageView.center.x
                    self.destinationPoint.y = containerView.frame.size.height + (self.referenceImageView.frame.size.width * sqrt(2))/2
                    self.originalImageView.hidden = false
                    self.duration *= 1.6
                    factor = 1.0
                    if self.shouldRotate {
                        rotation = CGFloat(M_PI_4)
                    }
                }
            }
            
            //View which holds the alpha animation
            var alphaView = UIView(frame: containerView.frame)
            alphaView.backgroundColor = self.presenting ? toViewController.view.backgroundColor : fromViewController.view.backgroundColor
            alphaView.alpha = self.presenting ? 0.0 : 1.0
            
            if self.presenting {
                //If the destination view controller is AJImageViewController
                containerView.addSubview(alphaView)
                self.referenceImageView.hidden = true
                containerView.addSubview(imageView)
            } else {
                //If back to the first View Controller
                fromViewController.view.removeFromSuperview()
                //                toViewController.view.frame.origin = CGPoint(x: 0, y: 0)
                containerView.addSubview(toViewController.view)
                containerView.addSubview(alphaView)
                containerView.addSubview(imageView)
            }
            
            UIView.animateWithDuration(self.duration, delay: 0, usingSpringWithDamping: (self.shouldBounce ? self.kDumping : 1.0), initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                imageView.transform = CGAffineTransformMakeScale(factor, factor)
                if let rotation = self.rotation {
                    imageView.transform = CGAffineTransformMakeRotation(rotation)
                }
                imageView.center = self.destinationPoint
                alphaView.alpha = self.presenting ? 1.0 : 0.0
                }) { (_) -> Void in
                    if !self.presenting {
                        self.originalImageView.hidden = false
                    }
                    //Removing animating views
                    alphaView.removeFromSuperview()
                    imageView.removeFromSuperview()
                    //                    toViewController.view.frame.origin = CGPoint(x: 0, y: 0)
                    containerView.addSubview(toViewController.view)
                    transitionContext.completeTransition(true)
                    if !self.presenting {
                        UIApplication.sharedApplication().keyWindow?.addSubview(toViewController.view)
                    }
                    self.presenting = !self.presenting
            }
            
        }
        
    }
    
}
