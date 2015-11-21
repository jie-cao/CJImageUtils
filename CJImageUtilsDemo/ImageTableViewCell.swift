//
//  ImageTableViewCell.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 11/21/15.
//  Copyright © 2015 JieCao. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.contentLabel.text = nil
        self.photoView.image = nil
        self.photoView.cancelImageFetch()
    }

}
