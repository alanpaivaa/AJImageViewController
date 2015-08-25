//
//  AJScrollView.swift
//  AJImageViewController
//
//  Created by Alan Jeferson on 22/08/15.
//  Copyright (c) 2015 AJWorks. All rights reserved.
//

import UIKit

class AJScrollView: UIScrollView, UIScrollViewDelegate {
    
    var imageView: UIImageView!
    var minScale: CGFloat!
    var loadIndicator: UIActivityIndicatorView!
    var fadeDuration: NSTimeInterval = 0.3
    
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        self.showLoadIndicator()
        self.imageView = UIImageView(image: image)
        self.imageView.alpha = 0
        self.setupViewAttrs()
        self.setupDoubleTapGesture()
        self.delegate = self
        self.zoom(toScale: self.minScale, animated: false)
        self.centerImageView()
        self.showImageView()
    }
    
    init(frame: CGRect, url: NSURL) {
        super.init(frame: frame)
        self.showLoadIndicator()
        self.loadImageFrom(url: url)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showLoadIndicator() -> Void {
        self.loadIndicator = UIActivityIndicatorView(frame: CGRect(origin: self.bounds.origin, size: self.bounds.size))
        self.loadIndicator.startAnimating()
        self.addSubview(self.loadIndicator)
    }
    
    private func hideLoadIndicator() -> Void {
        self.loadIndicator.hidden = true
        self.loadIndicator.stopAnimating()
        self.loadIndicator.removeFromSuperview()
        self.loadIndicator = nil
    }
    
    private func showImageView() -> Void {
        UIView.animateWithDuration(self.fadeDuration, animations: { () -> Void in
            self.loadIndicator.alpha = 0
            self.imageView.alpha = 1
            }) { (_) -> Void in
                self.hideLoadIndicator()
        }
    }
    
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
    
    private func zoom(toScale scale: CGFloat, animated: Bool) -> Void {
        let scrollViewSize = self.bounds.size
        let w = scrollViewSize.width / scale
        let h = scrollViewSize.height / scale
        let rectToZoom = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        self.zoomToRect(rectToZoom, animated: animated)
    }
    
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
    
    private func setupDoubleTapGesture() -> Void {
        var doubleTapGesture = UITapGestureRecognizer(target: self, action: Selector("doubleTapScrollView:"))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(doubleTapGesture)
    }
    
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
    
    //MARK:- ScrollView Delegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerImageView()
    }
    
}
