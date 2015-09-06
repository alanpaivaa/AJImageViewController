//
//  AJScrollView.swift
//  AJImageViewController
//
//  Created by Alan Jeferson on 22/08/15.
//  Copyright (c) 2015 AJWorks. All rights reserved.
//

import UIKit

class AJScrollView: UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    //Holder scrollView
    var superScroll: UIScrollView?
    
    var imageView: UIImageView!
    var loadIndicator: UIActivityIndicatorView!
    
    var panStarted = false
    
    var minScale: CGFloat!
    var delta = CGPoint(x: 0, y: 0)
    var imagePanOffset: CGFloat = 60.0
    var fadeDuration: NSTimeInterval = 0.3
    var imageBackToCenterAnimationTime: NSTimeInterval = 0.3
    
    //Blocks
    var dismissBlock: (() -> Void)?
    var showDissmissButtonBlock: ((Bool) -> Void)?
    
    private var tapGesture: UITapGestureRecognizer!
    private var doubleTapGesture: UITapGestureRecognizer!
    
    //MARK:- Init
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        self.showLoadIndicator()
        self.imageView = UIImageView(image: image)
        self.imageView.alpha = 0
        self.setupViewAttrs()
        self.setupDoubleTapGesture()
        self.setupSingleTapGesture()
        self.delegate = self
        self.zoom(toScale: self.minScale, animated: false)
        self.centerImageView()
        self.showImageView()
        self.setupImagePanGesture()
    }
    
    init(frame: CGRect, url: NSURL) {
        super.init(frame: frame)
        self.showLoadIndicator()
        self.loadImageFrom(url: url)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- View methods
    
    /** Shows the load indicator */
    private func showLoadIndicator() -> Void {
        self.loadIndicator = UIActivityIndicatorView(frame: CGRect(origin: self.bounds.origin, size: self.bounds.size))
        self.loadIndicator.startAnimating()
        self.addSubview(self.loadIndicator)
    }
    
    /** Hides the load indicator (used when finishing loading image) */
    private func hideLoadIndicator() -> Void {
        self.loadIndicator.hidden = true
        self.loadIndicator.stopAnimating()
        self.loadIndicator.removeFromSuperview()
        self.loadIndicator = nil
    }
    
    /** Do all the necessay work for when a image has finished loading */
    private func showImageView() -> Void {
        UIView.animateWithDuration(self.fadeDuration, animations: { () -> Void in
            self.loadIndicator.alpha = 0
            self.imageView.alpha = 1
            }) { (_) -> Void in
                self.hideLoadIndicator()
        }
    }
    
    /** Loads a image with the given NSURL */
    private func loadImageFrom(#url: NSURL) -> Void {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue, { () -> Void in
            let data = NSData(contentsOfURL: url)
            if let data = data {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.imageView = UIImageView(image: UIImage(data: data))
                    self.imageView.alpha = 0
                    self.setupViewAttrs()
                    self.setupDoubleTapGesture()
                    self.delegate = self
                    self.zoom(toScale: self.minScale, animated: false)
                    self.centerImageView()
                    
                    self.showImageView()
                })
            }
        })
    }
    
    /** Inits all the necessary views with the default values */
    private func setupViewAttrs() -> Void {
        //Indicators and content size
        self.showsHorizontalScrollIndicator =  false
        self.showsVerticalScrollIndicator = false
        self.contentSize = self.imageView.bounds.size
        
        //Setting up the max an min zoomscales for not allowing to zoom out more than the image size
        let scrollViewFrame = self.frame
        let scaleWidth = scrollViewFrame.size.width / self.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / self.contentSize.height
        self.minScale = min(scaleWidth, scaleHeight)
        self.minimumZoomScale = self.minScale
        self.maximumZoomScale = 3.0
        self.zoomScale = self.minScale
        
        //Adding image
        self.addSubview(self.imageView)
        
    }
    
    //MARK:- Gesture Reconizers methods
    
    /** Setups the scroll view to handle single tap gesture. (Work along the double tap) */
    func setupSingleTapGesture() -> Void {
        self.tapGesture = UITapGestureRecognizer(target: self, action: Selector("viewDidTap:"))
        self.tapGesture.numberOfTouchesRequired = 1
        self.tapGesture.numberOfTapsRequired = 1
        self.tapGesture.requireGestureRecognizerToFail(self.doubleTapGesture)
    }
    
    /** Selector for the single tap gesture. Dismiss the current view controller by calling the dismiss block */
    func viewDidTap(tapGesture: UITapGestureRecognizer) -> Void {
        if !CGRectContainsPoint(self.imageView.frame, tapGesture.locationInView(self)) && self.minScale == self.zoomScale {
            self.dismissBlock?()
        }
    }
    
    /** Adds/Remove the single tap gesture */
    func enableSingleTapGesture(enable: Bool) -> Void {
        if enable {
            self.addGestureRecognizer(self.tapGesture)
        } else {
            self.imageView.removeGestureRecognizer(self.tapGesture)
        }
    }
    
    /** Inits and setup the double tap gesture recognizer */
    private func setupDoubleTapGesture() -> Void {
        self.doubleTapGesture = UITapGestureRecognizer(target: self, action: Selector("doubleTapScrollView:"))
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.doubleTapGesture.numberOfTouchesRequired = 1
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(self.doubleTapGesture)
    }
    
    /** Adds the pan gesture to the image. Therefore allowing the image to pan when zoomed */
    private func setupImagePanGesture() -> Void {
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("imageDidPan:"))
        panGesture.delegate = self
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(panGesture)
    }
    
    /** Selector for when the pan gesture occurs on the image */
    func imageDidPan(panGesture: UIPanGestureRecognizer) -> Void {
        if self.minScale == self.zoomScale {
            let point = panGesture.locationInView(self)
            if panGesture.state == UIGestureRecognizerState.Began {
                self.delta.x = point.x - self.imageView.center.x
                self.delta.y = point.y - self.imageView.center.y
            } else if panGesture.state == UIGestureRecognizerState.Changed && self.superScroll!.bounds.origin.x == CGFloat(self.tag)*self.superScroll!.bounds.size.width && (self.panStarted || (panGesture.velocityInView(self).y != 0 && panGesture.velocityInView(self).x==0)) {
                self.superScroll?.scrollEnabled = false
                let center = CGPoint(x: point.x - self.delta.x, y: point.y - self.delta.y)
                self.imageView.center = center
                self.panStarted = true
                self.superScroll!.superview!.backgroundColor = self.superScroll!.superview!.backgroundColor!.colorWithAlphaComponent(1 - (abs(self.imageView.center.y - self.center.y) / (self.frame.height/2 + self.imageView.frame.size.height/2)))
            } else if panGesture.state == UIGestureRecognizerState.Ended {
                self.panStarted = false
                if abs(self.imageView.center.y - self.center.y) > self.imagePanOffset {
                    self.dismissBlock?()
                } else {
                    self.superScroll?.scrollEnabled = true
                    UIView.animateWithDuration(self.imageBackToCenterAnimationTime, animations: { () -> Void in
                        self.superScroll!.superview!.backgroundColor = self.superScroll!.superview!.backgroundColor!.colorWithAlphaComponent(1)
                        self.imageView.center = self.superScroll!.center
                    })
                }
            }
        }
    }
    
    /** Selector for when a double tap gesture occurs on the scroll view */
    func doubleTapScrollView(tapGesture: UITapGestureRecognizer) -> Void {
        let pointInView = tapGesture.locationInView(self.imageView)
        
        var newZoomScale = self.zoomScale * 1.5
        newZoomScale = min(newZoomScale, self.maximumZoomScale)
        
        let scrollViewSize = self.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w/2.0)
        let y = pointInView.y - (h/2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: w, height: h)
        self.zoomToRect(rectToZoom, animated: true)
    }
    
    //MARK:- Zoom methods
    
    /** Zooms the scrollView to the given scale */
    private func zoom(toScale scale: CGFloat, animated: Bool) -> Void {
        let scrollViewSize = self.bounds.size
        let w = scrollViewSize.width / scale
        let h = scrollViewSize.height / scale
        let rectToZoom = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        self.zoomToRect(rectToZoom, animated: animated)
    }
    
    /** Centers the imageView on the screen. Used after zooming */
    private func centerImageView() -> Void {
        let boundsSize = self.bounds.size
        var contentFrame = self.imageView.frame
        
        if contentFrame.size.width < boundsSize.width {
            contentFrame.origin.x = (boundsSize.width - contentFrame.size.width) / 2.0
        } else {
            contentFrame.origin.x = 0.0
        }
        
        if contentFrame.size.height < boundsSize.height {
            contentFrame.origin.y = (boundsSize.height - contentFrame.size.height) / 2.0
        } else {
            contentFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentFrame
    }
    
    //MARK:- ScrollView Delegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerImageView()
        self.superScroll?.scrollEnabled = false
        self.superScroll?.bounces = false
        self.bounces = false
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        self.superScroll?.scrollEnabled = self.minScale == self.zoomScale
        self.superScroll?.bounces = self.minScale == self.zoomScale
        self.bounces = self.minScale == self.zoomScale
        self.showDissmissButtonBlock?(self.zoomScale == self.minScale)
    }
    
    //MARK:- Gesture reconizer delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
