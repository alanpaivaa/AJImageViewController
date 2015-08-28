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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGestureRecognizers()
    }
    
    func setupGestureRecognizers() -> Void {
        let tapA = UITapGestureRecognizer(target: self, action: Selector("presentSingleImageViewController:"))
        tapA.numberOfTapsRequired = 1
        tapA.numberOfTouchesRequired = 1
        self.imageViewA.userInteractionEnabled = true
        self.imageViewA.addGestureRecognizer(tapA)
        
        let tapB = UITapGestureRecognizer(target: self, action: Selector("presentImageViewController:"))
        tapB.numberOfTapsRequired = 1
        tapB.numberOfTouchesRequired = 1
        self.imageViewB.userInteractionEnabled = true
        self.imageViewB.addGestureRecognizer(tapB)
    }
    
    func presentSingleImageViewController(gesture: UITapGestureRecognizer) -> Void {
        var imageViewController = AJImageViewController(imageView: self.imageViewA, images: UIImage(named: "image4")!)
        imageViewController.dismissButton.hidden = true
        imageViewController.enableSingleTapToDismiss = true
        self.presentViewController(imageViewController, animated: true, completion: nil)
    }
    
    func presentImageViewController(gesture: UITapGestureRecognizer) -> Void {
        let imageViewController = AJImageViewController(imageView: self.imageViewB, images: UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!, UIImage(named: "image4")!)
        self.presentViewController(imageViewController, animated: true, completion: nil)
    }
    
}

