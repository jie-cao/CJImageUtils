//
//  ImageCollectionCell.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 11/21/15.
//  Copyright © 2015 JieCao. All rights reserved.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.imageView.cancelImageFetch()
    }
}
