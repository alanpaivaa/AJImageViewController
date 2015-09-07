//
//  AJAwesomeTransition.swift
//  Pods
//
//  Created by Alan Jeferson on 25/08/15.
//
//

import UIKit

class AJAwesomeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var originalImageView: UIImageView!
    var referenceImageView: UIImageView!
    
    var shouldBounce: Bool = true
    var shouldRotate: Bool = false
    var presenting = true
    
    var duration: NSTimeInterval = 0.6
    private let kDumping: CGFloat = 0.8
    var rotation: CGFloat?
    var imageWidth: CGFloat!
    
    private var destinationPoint: CGPoint!
    private var originalImageCenter: CGPoint!
    
    var dismissalType = AJImageViewDismissalType.OriginalImage
    
    func showOriginalImage(show: Bool) -> Void {
        self.originalImageView.hidden = !show
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return self.duration
    }
    
    /** Converts the given point from the fromView coordinate system to the toView coordinate system */
    func convert(#point: CGPoint, fromView: UIView, toView: UIView) -> CGPoint {
        return fromView.superview!.convertPoint(point, toView: toView)
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        //Keeps a reference to the image view from the first view controller
        self.originalImageView = self.originalImageView ?? self.referenceImageView
        
        let containerView = transitionContext.containerView()
        
        //Setups the image view which holds the scale and move animations
        var imageView = UIImageView(frame: self.referenceImageView.frame)
        imageView.image = self.referenceImageView.image
        imageView.contentMode = self.originalImageView.contentMode
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = self.originalImageView.layer.borderWidth
        
        //Factor to scale the animating image
        var size: CGSize!
        var factor: CGFloat!
        
        if self.presenting {
            size = self.referenceImageView.image!.size
            factor = size.width / size.height
        } else {
            size = self.originalImageView.frame.size
        }
        
        if let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey), toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            
            //Setting up destination point
            if let toViewController = toViewController as? AJImageViewController {
                self.originalImageCenter = self.referenceImageView.center
                self.destinationPoint = containerView.center
            } else {
                //If user did not chang page image after dismissing
                if self.dismissalType == AJImageViewDismissalType.OriginalImage {
                    self.destinationPoint = self.convert(point: self.originalImageCenter, fromView: self.originalImageView, toView: containerView)
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
                let newOrigin = self.convert(point: self.referenceImageView.frame.origin, fromView: self.referenceImageView, toView: containerView)
                imageView.frame.origin = newOrigin
                containerView.addSubview(imageView)
            } else {
                //If back to the first View Controller
                fromViewController.view.removeFromSuperview()
                containerView.addSubview(toViewController.view)
                containerView.addSubview(alphaView)
                containerView.addSubview(imageView)
            }
            
            //Animating the corner radius
            let animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fromValue = self.presenting ? self.referenceImageView.layer.cornerRadius : 0.0
            animation.toValue = self.presenting ? 0.0 : self.originalImageView.layer.cornerRadius
            animation.duration = self.duration/2
            imageView.layer.cornerRadius = self.presenting ? 0.0 : self.originalImageView.layer.cornerRadius
            imageView.layer.addAnimation(animation, forKey: "cornerRadius")
            
            let animationBorder = CABasicAnimation(keyPath: "borderColor")
            animationBorder.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animationBorder.fromValue = self.presenting ? self.referenceImageView.layer.borderColor : UIColor.clearColor().CGColor
            animationBorder.toValue = self.presenting ? UIColor.clearColor().CGColor : self.originalImageView.layer.borderColor
            animationBorder.duration = self.duration/4
            imageView.layer.borderColor = self.presenting ? UIColor.clearColor().CGColor : self.originalImageView.layer.borderColor
            imageView.layer.addAnimation(animationBorder, forKey: "borderColor")
            
            
            UIView.animateWithDuration(self.duration, delay: 0, usingSpringWithDamping: (self.shouldBounce ? self.kDumping : 1.0), initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                imageView.frame.size.width = self.presenting ? containerView.frame.size.width : size.width
                imageView.frame.size.height = self.presenting ? (containerView.frame.size.width / factor) : size.height
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
                    containerView.addSubview(toViewController.view)
                    if !self.presenting {
                        UIApplication.sharedApplication().keyWindow?.addSubview(toViewController.view)
                    }
                    self.presenting = !self.presenting
                    transitionContext.completeTransition(true)
            }
            
        }
        
    }
    
}
