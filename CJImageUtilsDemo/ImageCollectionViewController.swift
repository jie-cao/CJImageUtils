//
//  ImageCollectionViewController.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 11/20/15.
//  Copyright © 2015 JieCao. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

class ImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = [["text":"cat", "url":"http://www.fndvisions.org/img/cutecat.jpg"],
            ["text":"cat", "url":"http://www.mycatnames.com/wp-content/uploads/2015/09/Great-Ideas-for-cute-cat-names-2.jpg"],
            ["text":"cat", "url":"http://cdn.cutestpaw.com/wp-content/uploads/2011/11/cute-cat.jpg"],
            ["text":"cat", "url":"http://buzzneacom.c.presscdn.com/wp-content/uploads/2015/02/cute-cat-l.jpg"],
            ["text":"cat", "url":"http://images.fanpop.com/images/image_uploads/CUTE-CAT-cats-625629_689_700.jpg"],
            ["text":"cat", "url":"http://cl.jroo.me/z3/m/a/z/e/a.baa-Very-cute-cat-.jpg"],
            ["text":"cat", "url":"http://www.cancats.net/wp-content/uploads/2014/10/cute-cat-pictures-the-cutest-cat-ever.jpg"],
            ["text":"cat", "url":"https://catloves9.files.wordpress.com/2012/05/cute-cat-20.jpg"],
            ["text":"cat", "url":"https://s-media-cache-ak0.pinimg.com/736x/8c/99/e3/8c99e3483387df6395da674a6b5dee4c.jpg"],
            ["text":"cat", "url":"http://youne.com/wp-content/uploads/2013/09/cute-cat.jpg"],
            ["text":"cat", "url":"http://www.lovefotos.com/wp-content/uploads/2011/06/cute-cat1.jpg"],
            ["text":"cat", "url":"http://cutecatsrightmeow.com/wp-content/uploads/2015/10/heres-looking-at-you-kid.jpg"]]
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(ImageCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.alwaysBounceVertical = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.dataSource.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let data = self.dataSource[indexPath.row] as! [String :String]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionCell
        if let imageUrl = NSURL(string: data["url"]!){
            cell.imageView?.imageWithURL(imageUrl)
            cell.imageView?.contentMode = .ScaleAspectFill
        }
        // Configure the cell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 100)
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
