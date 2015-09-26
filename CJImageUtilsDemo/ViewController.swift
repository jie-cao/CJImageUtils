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
        let url = NSURL(string: "http://my10online.com/wp-content/uploads/2011/09/4480604.jpg")
        imageView.imageWithURL(url!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

