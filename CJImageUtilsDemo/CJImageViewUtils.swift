//
//  CJImageViewUtils.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 9/23/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

// MARK: - Associated Object
private var lastURLKey: Void?

extension UIImageView{
    
    /// Get the image URL binded to this image view.
    public var getWebURL: NSURL? {
        get {
            return objc_getAssociatedObject(self, &lastURLKey) as? NSURL
        }
    }
    
    private func setDownloadKey(URL: NSURL) {
        objc_setAssociatedObject(self, &lastURLKey, URL, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
    
    func imageWithURL(url:NSURL, options: CJImageFetchOptions? = nil){
        CJImageUtilsManager.sharedInstance.retrieveImageFromUrl(url, options: options, completionBlock: { (image, data, error, finished) -> Void in
            dispatch_async(dispatch_get_main_queue(), {()->Void in
                self.image = image
            })},
            progressBlock: nil);
    }
    
    func imageWithURLString(urlString:String, options:CJImageFetchOptions? = nil){
        if let url = NSURL(string: urlString) {
            self.imageWithURL(url, options: options)
        }
    }
}
