//
//  CJImageCache.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 6/12/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit
import CoreGraphics

enum CacheType {
    case None, Memory, File
}

class CJImageCache: NSObject {
    private static let ioQueueName = "com.jiecao.CJImageUtils.ImageCache.ioQueue"
    private static let processQueueName = "com.jiecao.CJImageUtils.ImageCache.processQueue"
    private static let cacheName = "com.jiecao.CJImageUtils.ImageCache.CacheName"
    static let sharedInstance = CJImageCache()
    
    var maxCacheAge:NSTimeInterval = 60 * 60 * 24 * 7
    var memoryCache : NSCache = NSCache()
    var fileManager : NSFileManager = NSFileManager()
    var filesFolder : NSURL!
    private let ioQueue: dispatch_queue_t = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_SERIAL)
    private let processQueue: dispatch_queue_t = dispatch_queue_create(processQueueName, DISPATCH_QUEUE_CONCURRENT)
    
    override init(){
        super.init()
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        filesFolder = NSURL(fileURLWithPath:paths.first!).URLByAppendingPathComponent(CJImageCache.cacheName)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearMemoryCache", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cleanExpiredDiskCache", name: UIApplicationWillTerminateNotification, object: nil)
    }
    
    deinit{
         NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func clearMemoryCache(){
        memoryCache.removeAllObjects()
    }
    
    func clearDiskCache(){
        dispatch_async(ioQueue, { () -> Void in
            do {
                try self.fileManager.removeItemAtPath(self.filesFolder.path!)
            } catch _ {
            }
            do {
                try self.fileManager.createDirectoryAtPath(self.filesFolder.path!, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        })
    }
    
    func storeImage(image:UIImage, key:String, imageData:NSData? = nil, cachePolicy:CJImageCachePolicy, completionHandler:(()-> Void)?){
        if (cachePolicy.rawValue | CJImageCachePolicy.MemoryCache.rawValue) != 0 {
            self.memoryCache.setObject(image, forKey: key)
        }
        
        if (cachePolicy.rawValue | CJImageCachePolicy.FileCache.rawValue) != 0 {
            dispatch_async(ioQueue, {()-> Void in
                var data:NSData?
                if (CJImageUtils.isPNG(image, imageData: imageData)) {
                    data = UIImagePNGRepresentation(image);
                }
                else {
                    data = UIImageJPEGRepresentation(image, 1.0)
                }
                
                if data != nil {
                    if !self.fileManager.fileExistsAtPath(self.filesFolder!.path!){
                        do {
                            try self.fileManager.createDirectoryAtURL(self.filesFolder, withIntermediateDirectories: true, attributes: nil)
                        } catch _ {
                            print("Cannot create file at file URL: \(self.fileManager)")
                        }
                    }
                    self.fileManager.createFileAtPath(self.cachePathForKey(key), contents: data!, attributes: nil)
                    
                }
            })
            
        }
        
        if let handler = completionHandler {
            handler()
        }
    }
    
    func retrieveImageForKey(key: String, options:CJImageFetchOptions, completionHandler: ((UIImage?, CacheType!) -> Void)?) {
        
        if let image = self.retrieveImageFromMemoryCache(key) {
            
            //Found image in memory cache.
            var result:UIImage? = nil
            if options.shouldDecode {
                dispatch_async(self.processQueue, { () -> Void in
                    result = CJImageUtils.DecodImage(image, scale: options.scale)
                })
            }
            
            result = result == nil ? image : result
            if let handler = completionHandler {
                handler(result, .Memory)
            }
        } else {
            //Begin to load image from disk
            dispatch_async(ioQueue, { () -> Void in
                
                if let image = self.retrieveImageForFile(key, scale: options.scale) {
                    
                    if options.shouldDecode {
                        dispatch_async(self.processQueue, { () -> Void in
                            let result = CJImageUtils.DecodImage(image, scale: options.scale)
                            self.storeImage(result!, key: key, cachePolicy: options.cachePolicy, completionHandler: nil)
                            
                            if let handler = completionHandler {
                                handler(result, .File)
                                
                            }
                        })
                    } else {
                        self.storeImage(image, key: key, cachePolicy: options.cachePolicy, completionHandler: nil)
                        if let handler = completionHandler {
                            handler(image, .File)
                        }
                    }
                    
                } else {
                    
                    if let handler = completionHandler {
                        handler(nil, nil)
                    }
                }
            })
        }
    }
    
    func retrieveImageFromMemoryCache(key: String) -> UIImage? {
        return memoryCache.objectForKey(key) as? UIImage
    }
    
    func retrieveImageForFile(key: String, scale: CGFloat = 1.0) -> UIImage? {
        if let data = loadImageDataFromFile(key),
            let image = UIImage(data: data, scale: scale) {
                return image
        } else {
            return nil
        }
    }
    
    func loadImageDataFromFile(key: String) -> NSData? {
        let filePath = cachePathForKey(key)
        return NSData(contentsOfFile: filePath)
    }
    
    func cachePathForKey(key: String) -> String {
        let fileName = cacheFileNameForKey(key)
        return self.filesFolder!.URLByAppendingPathComponent(fileName).path!
    }
    
    func cacheFileNameForKey(key: String) -> String {
        return key.toMD5()
    }
}
