//
//  ViewController.swift
//  AJImageViewController
//
//  Created by Alan Jeferson on 21/08/15.
//  Copyright (c) 2015 AJWorks. All rights reserved.
//

import UIKit

public class AJImageViewController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    var scrollView: UIScrollView!
    
    var images = [UIImage]()
    var urls = [NSURL]()
    
    var pages = [AJScrollView?]()
    var currentPage = 0
    var loadedPagesOffset = 1
    let sideOffset: CGFloat = 10.0
    
    var dismissButtonImage: UIImage!
    var imageWidth: CGFloat!
    var originalImageCenter: CGPoint!
    private var firstPage: Int!
    
    private var loadType = AJImageViewControllerLoadType.LoadFromLocalImages
    private var itensCount = 0
    
    private var transition = AJAwesomeTransition()
    
    public init(imageView: UIImageView, images: UIImage ...) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
        self.setupTransitionWith(imageView: imageView)
    }
    
    public init(imageView: UIImageView, urls: NSURL ...) {
        super.init(nibName: nil, bundle: nil)
        self.urls = urls
        self.setupTransitionWith(imageView: imageView)
    }
    
    private func setupTransitionWith(#imageView: UIImageView) -> Void {
        self.imageWidth = imageView.frame.size.width
        self.originalImageCenter = imageView.center
        self.transition.referenceImageView = imageView
        self.transition.imageWidth = self.view.frame.size.width
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.firstPage = self.currentPage
        self.transitioningDelegate = self
        self.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.view.backgroundColor = UIColor.blackColor()
        self.setupSuperSCrollView()
        self.setupPagging()
        self.addDismissButton()
    }
    
    func setupSuperSCrollView() -> Void {
        self.scrollView = UIScrollView(frame: self.view.frame)
        self.view.addSubview(self.scrollView)
        self.scrollView.pagingEnabled = true
        
        //Setup the side offset to give a blank space between each image
        self.scrollView.frame.size.width += 2*self.sideOffset
        self.scrollView.frame.origin.x -= self.sideOffset
    }
    
    func setupPagging() -> Void {
        self.scrollView.delegate = self
        
        //Setup load type
        if self.images.count == 0 {
            self.loadType = AJImageViewControllerLoadType.LoadFromUrls
        }
        
        //Counting the number of itens
        self.setupItemCount()
        
        //Create page holders
        for _ in 0..<self.itensCount {
            self.pages.append(nil)
        }
        
        //Setup scroll view
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(self.itensCount), height: self.scrollView.frame.size.height)
        self.scrollView.contentOffset.x = CGFloat(self.currentPage) * self.scrollView.frame.width
        
        //Creates the current page and the - and + page offset
        self.loadVisiblePages()
    }
    
    private func setupItemCount() -> Void {
        if self.loadType == AJImageViewControllerLoadType.LoadFromLocalImages {
            self.itensCount = self.images.count
        } else {
            self.itensCount = self.urls.count
        }
    }
    
    func load(#page: Int) -> Void {
        
        if page>=0 && page<self.itensCount {
            
            if self.pages[page] == nil {
                //Init inside image and scroll
                var frame = self.scrollView.frame
                frame.origin.x = CGFloat(page) * self.scrollView.frame.width
                frame.origin.x += self.sideOffset
                frame.size.width -= 2*self.sideOffset
                
                var insideScroll: AJScrollView!
                var imageForZooming: UIImageView
                
                if self.loadType == AJImageViewControllerLoadType.LoadFromLocalImages {
                    insideScroll = AJScrollView(frame: frame, image: self.images[page])
                } else {
                    insideScroll = AJScrollView(frame: frame, url: self.urls[page])
                }
                
                
                insideScroll.dismissBlock = self.dismissViewController
                insideScroll.superScroll = self.scrollView
                insideScroll.tag = page
                
                //Adding subviews
                self.scrollView.addSubview(insideScroll)
                
                self.pages[page] = insideScroll
            }
        }
    }
    
    func purge(#page: Int) -> Void {
        if page>=0 && page<self.itensCount {
            if let pageView = self.pages[page] {
                pageView.removeFromSuperview()
                self.pages[page] = nil
            }
        }
    }
    
    func loadVisiblePages() -> Void {
        let firstPage = self.currentPage - self.loadedPagesOffset
        let lastPage = self.currentPage + self.loadedPagesOffset
        
        //Dealocating pages
        for var index = 0; index<firstPage; ++index {
            self.purge(page: index)
        }
        
        //Allocating pages
        for i in firstPage...lastPage {
            self.load(page: i)
        }
        
        //Dealocating pages
        for var index = lastPage+1; index<self.itensCount; ++index {
            self.purge(page: index)
        }
    }
    
    private func addDismissButton() -> Void {
        let buttonSize: CGFloat = 44.0
        let buttonOffset: CGFloat = 5.0
        let buttonInset: CGFloat = 12.0
        let button = UIButton(frame: CGRect(x: buttonOffset, y: buttonOffset, width: buttonSize, height: buttonSize))
        button.contentEdgeInsets = UIEdgeInsets(top: buttonInset, left: buttonInset, bottom: buttonInset, right: buttonInset)
        let podBundle = NSBundle(forClass: self.classForCoder)
        
        if self.dismissButtonImage == nil {
            if let bundlePath = podBundle.URLForResource("AJImageViewController", withExtension: "bundle"), bundle = NSBundle(URL: bundlePath), image = UIImage(named: "delete", inBundle: bundle, compatibleWithTraitCollection: nil) {
                self.dismissButtonImage = image
            }
        }
        
        button.setImage(self.dismissButtonImage, forState: UIControlState.Normal)
        button.addTarget(self, action: Selector("dismissViewController"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func dismissViewController() -> Void {
        self.transition.referenceImageView = self.pages[self.currentPage]!.imageView
        self.transition.imageWidth = self.imageWidth
        if self.currentPage != self.firstPage {
            self.transition.dismissalType = AJImageViewDismissalType.DisappearBottom
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK:- ScrollView delegate
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var page = Int(self.scrollView.contentOffset.x / self.scrollView.frame.width)
        if page != self.currentPage {
            self.currentPage = page
            self.loadVisiblePages()
        }
    }
    
    //MARK:- Transition Delegate
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transition
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transition
    }
}

