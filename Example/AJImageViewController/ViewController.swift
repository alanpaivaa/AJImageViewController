//
//  ViewController.swift
//  AJImageViewController
//
//  Created by Alan Jeferson on 08/24/2015.
//  Copyright (c) 2015 Alan Jeferson. All rights reserved.
//

import UIKit
import AJImageViewController

class ViewController: UIViewController {
    
    @IBOutlet weak var imageViewA: UIImageView!
    @IBOutlet weak var imageViewB: UIImageView!
    @IBOutlet weak var imageViewC: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupImageViewA()
        self.setupGestureRecognizers()
    }
    
    func setupImageViewA() -> Void {
        self.imageViewA.clipsToBounds = true
        self.imageViewA.layer.cornerRadius = self.imageViewA.frame.width/2
        self.imageViewA.layer.borderWidth = 3.0
        self.imageViewA.layer.borderColor = UIColor.purpleColor().CGColor
    }
    
    func setupGestureRecognizers() -> Void {
        let tapA = UITapGestureRecognizer(target: self, action: Selector("presentSingleImageViewControllerA:"))
        tapA.numberOfTapsRequired = 1
        tapA.numberOfTouchesRequired = 1
        self.imageViewA.userInteractionEnabled = true
        self.imageViewA.addGestureRecognizer(tapA)
        
        let tapB = UITapGestureRecognizer(target: self, action: Selector("presentImageViewController:"))
        tapB.numberOfTapsRequired = 1
        tapB.numberOfTouchesRequired = 1
        self.imageViewB.userInteractionEnabled = true
        self.imageViewB.addGestureRecognizer(tapB)
        
        let tapC = UITapGestureRecognizer(target: self, action: Selector("presentSingleImageViewControllerC:"))
        tapC.numberOfTapsRequired = 1
        tapC.numberOfTouchesRequired = 1
        self.imageViewC.userInteractionEnabled = true
        self.imageViewC.addGestureRecognizer(tapC)
    }
    
    func presentSingleImageViewControllerA(gesture: UITapGestureRecognizer) -> Void {
        var imageViewController = AJImageViewController(imageView: self.imageViewA, images: UIImage(named: "image4")!)
        imageViewController.dismissButton.hidden = true
        imageViewController.enableSingleTapToDismiss = true
        self.presentViewController(imageViewController, animated: true, completion: nil)
    }
    
    func presentImageViewController(gesture: UITapGestureRecognizer) -> Void {
        let imageViewController = AJImageViewController(imageView: self.imageViewB, images: UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!, UIImage(named: "image4")!)
        self.presentViewController(imageViewController, animated: true, completion: nil)
    }
    
    func presentSingleImageViewControllerC(gesture: UITapGestureRecognizer) -> Void {
        var imageViewController = AJImageViewController(imageView: self.imageViewC, images: self.imageViewC.image!)
        imageViewController.dismissButton.hidden = true
        imageViewController.enableSingleTapToDismiss = true
        self.presentViewController(imageViewController, animated: true, completion: nil)
    }
    
}

