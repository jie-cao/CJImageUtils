//
//  CJImageUtilsManager.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 9/22/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

enum CJImageOptions {
    
    /**
    * By default, image downloads are started during UI interactions, this flags disable this feature,
    * leading to delayed download on UIScrollView deceleration for instance.
    */
    case CJImageOptionDefaultPriority
    
    /**
    * By default, image downloads are started during UI interactions, this flags disable this feature,
    * leading to delayed download on UIScrollView deceleration for instance.
    */
    case CJImageOptionLowPriority
    
    /**
    * By default, image downloads are started during UI interactions, this flags disable this feature,
    * leading to delayed download on UIScrollView deceleration for instance.
    */
    case CJImageOptionHighPriority
    
    /**
    * This flag disables on-disk caching
    */
    case CJImageOptionMemoryCacheOnly
    
    /**
    * This flag disables on-disk caching
    */
    case CJImageOptionFileCacheOnly
    
    /**
    * This flag disables on-disk caching
    */
    case CJImageOptionNoCache
}


class CJImageUtilsManager: NSObject {
    
    static let sharedInstance = CJImageUtilsManager()
    
    var imageDownloadOperationQueue = [String:CJImageDownloadOperation]()
    private static let ioQueueName = "com.jiecao.CJImageUtils.ImageManager.ioQueue"
    private let ioQueue: dispatch_queue_t = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_CONCURRENT)
    
    class func defaultKeyConverter(urlString:NSURL)->String?{
        return urlString.absoluteString
    }
    
    func cancelAll(){
        dispatch_barrier_async(self.ioQueue, { () -> Void in
            for (key, downloadOperation) in self.imageDownloadOperationQueue {
                downloadOperation.cancel()
            }
            self.imageDownloadOperationQueue.removeAll(keepCapacity: false)
        })
    }
    
    func cancel(operationKey:String){
        if let downloadOperation = self.fetchOperationForKey(operationKey){
            downloadOperation.cancel()
        }
        self.removeOperationForKey(operationKey)
    }
    
    func fetchOperationForKey(key: String) -> CJImageDownloadOperation? {
        var downloadOperation: CJImageDownloadOperation?
        dispatch_sync(self.ioQueue, { () -> Void in
            downloadOperation = self.imageDownloadOperationQueue[key]
        })
        return downloadOperation
    }
    
    func removeOperationForKey(key: String) {
        dispatch_barrier_async(self.ioQueue, { () -> Void in
            self.imageDownloadOperationQueue.removeValueForKey(key)
            return
        })
    }
    
    func retrieveImageFromUrl(url:NSURL, option:CJImageOptions, completionBlock:((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)?, progressBlock:((receivedSize:Int64, expectedSize:Int64)->Void)?) -> String? {
        
        if let imageDownloadOperation = self.fetchOperationForKey(url.absoluteString!){
            if progressBlock != nil {
                imageDownloadOperation.addProgressBlock(progressBlock!)
            }
            if completionBlock != nil {
                imageDownloadOperation.addCompletionBlock(completionBlock!)
            }
        } else {
            
            var imageFetchOperation = CJImageDownloadOperation(url: url, shouldDecode: true, progressBlock: progressBlock, completionBlock: completionBlock)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                imageFetchOperation.start()
            })
        }
        
        return url.absoluteString!
    }
}
