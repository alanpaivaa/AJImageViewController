//
//  Enums.swift
//  AJImageViewController
//
//  Created by Alan Jeferson on 22/08/15.
//  Copyright (c) 2015 AJWorks. All rights reserved.
//

import Foundation

/** Indicates if the images in AJImageViewController are loaded from local images ot through urls */
enum AJImageViewControllerLoadType {
    case LoadFromUrls
    case LoadFromLocalImages
}

/** Indicates the AJImageViewController dismiss type */
enum AJImageViewDismissalType {
    case OriginalImage
    case DisappearBottom
}
