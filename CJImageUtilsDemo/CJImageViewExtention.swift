//
//  CJImageViewExtension.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 6/14/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

// MARK: - Associated Key
private var lastURLKey: Void?

extension UIImageView{
    
    /// Get the image URL binded to this image view.
    public func getFetchKey()-> NSString?{
        return objc_getAssociatedObject(self, &lastURLKey) as? NSString
    }
    
    private func setFetchKey(key: NSString) {
        objc_setAssociatedObject(self, &lastURLKey, key, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func imageWithURL(url:NSURL){
        let options = CJImageFetchOptions()
        self.imageWithURL(url, options: options, placeholderImage: nil, progressHandler: nil)
    }
    
    func imageWithURL(url:NSURL, options: CJImageFetchOptions?){
        self.imageWithURL(url, options: options, placeholderImage: nil, progressHandler: nil)
    }
    
    func imageWithURL(url:NSURL, options: CJImageFetchOptions?, placeholderImage:UIImage?){
        self.imageWithURL(url, options: options, placeholderImage: placeholderImage, progressHandler: nil)
    }
    
    func imageWithURL(url:NSURL, options: CJImageFetchOptions?, placeholderImage:UIImage?, progressHandler:ProgressHandler?){
        self.imageWithURL(url, options: options, placeholderImage: placeholderImage, progressHandler: progressHandler, completionHandler: nil)
    }
    
    func imageWithURL(url:NSURL,
                  options:CJImageFetchOptions?,
         placeholderImage:UIImage?,
           progressHandler:ProgressHandler?,
        completionHandler:CompletionHandler?)
    {
        if let fetchKey = CJImageFetchManager.sharedInstance.retrieveImageFromUrl(url, options: options, completionHandler: { (image, data, error, finished) -> Void in
                dispatch_async(dispatch_get_main_queue(), {()->Void in
                    self.image = image
                })
                if let handler = completionHandler{
                    handler(image: image, data: data, error: error, finished: finished)
                }
            },
            progressHandler: progressHandler) {
                self.setFetchKey(fetchKey)
        }
    }
    
    func cancelImageFetch(){
        if let fetchKey = self.getFetchKey(){
            CJImageFetchManager.sharedInstance.removeOperationForKey(String(fetchKey))
        }
    }
    
}
