//
//  CJImageCache.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 9/21/15.
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
    private let cacheName = "com.jiecao.CJImageUtils.ImageCache.CacheName"
    
    static let sharedInstance = CJImageCache()
    
    var memoryCache : NSCache = NSCache()
    var fileManager : NSFileManager = NSFileManager()
    var filesFolder : String!
    private let ioQueue: dispatch_queue_t = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_SERIAL)
    private let processQueue: dispatch_queue_t = dispatch_queue_create(processQueueName, DISPATCH_QUEUE_CONCURRENT)
    
    override init(){
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        filesFolder = (paths.first as! String).stringByAppendingPathComponent(cacheName)
    }
    
    func storeImage(image:UIImage, key:String, imageData:NSData? = nil, cachePolicy:CJImageCachePolicy, completionHandler:(()-> Void)?){
        if cachePolicy == .CJImageOptionMemoryAndFileCache || cachePolicy == .CJImageOptionMemoryCacheOnly {
            self.memoryCache.setObject(image, forKey: key)
        }
        
        if cachePolicy == .CJImageOptionMemoryAndFileCache || cachePolicy == .CJImageOptionFileCacheOnly {
            dispatch_async(ioQueue, {()-> Void in
                var data:NSData?
                if (CJImageUtils.isPNG(image, imageData: imageData)) {
                    data = UIImagePNGRepresentation(image);
                }
                else {
                    data = UIImageJPEGRepresentation(image, 1.0)
                }
                
                if data != nil {
                    if !self.fileManager.fileExistsAtPath(self.filesFolder!){
                        self.fileManager.createDirectoryAtPath(self.filesFolder, withIntermediateDirectories: true, attributes: nil, error: nil)
                    }
                    
                    let success = self.fileManager.createFileAtPath(self.cachePathForKey(key), contents: data!, attributes: nil)
                    
                }
            })
            
        }
        
        if let completionBlock = completionHandler {
            completionBlock()
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
        return self.filesFolder!.stringByAppendingPathComponent(fileName)
    }
    
    func cacheFileNameForKey(key: String) -> String {
        return key.toMD5()
    }
}
