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
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGestureRecognizer()
    }
    
    func setupGestureRecognizer() -> Void {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("presentImageViewController:"))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    func presentImageViewController(gesture: UITapGestureRecognizer) -> Void {
        let imageViewController = AJImageViewController(images: UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!, UIImage(named: "image4")!)
//        let imageViewController = AJImageViewController(urls: NSURL(string: "https://pixabay.com/static/uploads/photo/2013/10/09/02/26/beach-192975_640.jpg")!, NSURL(string: "https://pixabay.com/static/uploads/photo/2015/08/17/01/30/01-30-07-194_640.jpg")!, NSURL(string: "https://pixabay.com/static/uploads/photo/2013/10/02/23/03/dawn-190055_640.jpg")!, NSURL(string: "https://pixabay.com/static/uploads/photo/2015/07/08/19/28/summer-836773_640.jpg")!)
        self.presentViewController(imageViewController, animated: true, completion: nil)
//        let singleImageController = AJSingleImageViewController(imageView: self.imageView)
//        self.presentViewController(singleImageController, animated: true, completion: nil)
    }
    
}

