//
//  CJImageFetchManager.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 6/13/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

class CJImageFetchManager: NSObject {
    
    static let sharedInstance = CJImageFetchManager()
    
    var imageDownloadOperationQueue = [String:CJImageFetchOperation]()
    private static let ioQueueName = "com.jiecao.CJImageUtils.CJImageFetchManager.ioQueue"
    private let ioQueue: dispatch_queue_t = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_CONCURRENT)
    
    class func defaultKeyConverter(urlString:NSURL)->String?{
        return urlString.absoluteString
    }
    
    func cancelAll(){
        dispatch_barrier_async(self.ioQueue, { () -> Void in
            for (_, downloadOperation) in self.imageDownloadOperationQueue {
                downloadOperation.cancel()
            }
            self.imageDownloadOperationQueue.removeAll(keepCapacity: false)
        })
    }
    
    func cancel(operation:CJImageFetchOperation){
        operation.cancel();
        self.removeOperationForKey(operation.key!)
    }
    
    func fetchOperationForKey(key: String) -> CJImageFetchOperation? {
        var downloadOperation: CJImageFetchOperation?
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
    
    func addOperationForKey(key: String, operation:CJImageFetchOperation) {
        dispatch_barrier_async(self.ioQueue, { () -> Void in
            self.imageDownloadOperationQueue[key] = operation
            return
        })
    }
    
    func retrieveImageFromUrl(url:NSURL, options:CJImageFetchOptions? = nil, completionHandler:((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)?, progressHandler:((receivedSize:Int64, expectedSize:Int64)->Void)?) -> CJImageFetchOperation? {
        
        if  let operationKey = CJImageFetchManager.defaultKeyConverter(url),
            let imageDownloadOperation = self.fetchOperationForKey(operationKey){
            if progressHandler != nil {
                imageDownloadOperation.addProgressHandler(progressHandler!)
            }
            if completionHandler != nil {
                imageDownloadOperation.addCompletionHandler(completionHandler!)
            }
            return imageDownloadOperation;
        } else {
            
            let fetchOptios = options != nil ? options! : CJImageFetchOptions()
            
            let imageFetchOperation = CJImageFetchOperation(url: url, options: fetchOptios, progressHandler: progressHandler, completionHandler: completionHandler)
            
            self.addOperationForKey(imageFetchOperation.key!, operation: imageFetchOperation)
            
            var downloadPriority:Int = DISPATCH_QUEUE_PRIORITY_DEFAULT
            if fetchOptios.priority == .HighPriority {
                downloadPriority = DISPATCH_QUEUE_PRIORITY_HIGH
            } else if fetchOptios.priority == .LowPriority {
                downloadPriority = DISPATCH_QUEUE_PRIORITY_LOW
            }
            
            
            dispatch_async(dispatch_get_global_queue(downloadPriority, 0), { () -> Void in
                imageFetchOperation.start()
            })
            
            return imageFetchOperation;
        }
    }
}
