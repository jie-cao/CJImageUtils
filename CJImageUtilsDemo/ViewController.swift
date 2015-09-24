//
//  ViewController.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 9/21/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func viewWillAppear(animated: Bool) {
        imageView.imageWithURLString("http://ec2.images-amazon.com/images/I/71COQTGIb9L._AA1500_.jpg")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

