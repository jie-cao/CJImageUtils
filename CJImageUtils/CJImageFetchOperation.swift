//
//  CJImageFetchOperation.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 6/13/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

public enum ImageDownloadOperationErrorCode: Int {
    case BadData = 10000
    case NotModified = 10001
    case InvalidURL = 20000
}

public typealias ProgressHandler = ((receivedSize:Int64, expectedSize:Int64)->Void)
public typealias CompletionHandler = ((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)

class CJImageFetchOperation: NSObject, NSURLSessionTaskDelegate{
    
    private static let ioQueueName = "com.jiecao.CJImageUtils.ImageDownloadOption.ioQueue"
    let ImageDownloadOperationErrorDomain = "com.jiecao.CJImageDownloaderOperation.Error"
    
    var responseData:NSMutableData = NSMutableData()
    var isCancelled:Bool = false
    var sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    var session:NSURLSession?
    var sessionDataTask:NSURLSessionDataTask?
    var progressHandlers = [ProgressHandler]()
    var completionHandlers = [CompletionHandler]()
    var shouldDecode:Bool = false
    var url:NSURL?
    var key:String?
    var options:CJImageFetchOptions!
    
    private let ioQueue: dispatch_queue_t = dispatch_queue_create(ioQueueName, DISPATCH_QUEUE_SERIAL)
    
    init(url:NSURL, options:CJImageFetchOptions, progressHandler:((receivedSize:Int64, expectedSize:Int64)->Void)?, completionHandler:((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)?)
    {
        self.url = url
        self.key = CJImageFetchManager.defaultKeyConverter(url)
        
        if (progressHandler != nil){
            self.progressHandlers.append(progressHandler!)
        }
        if (completionHandler != nil){
            self.completionHandlers.append(completionHandler!)
        }
        
        self.options = options
        
        self.shouldDecode = self.options.shouldDecode
    }
    
    func addProgressHandler(progressHandler:ProgressHandler){
        dispatch_barrier_async(self.ioQueue, { () -> Void in
            self.progressHandlers.append(progressHandler)
        })
    }
    
    func addCompletionHandler(completionHandler:CompletionHandler){
        dispatch_barrier_async(self.ioQueue, { () -> Void in
            self.completionHandlers.append(completionHandler)
        })
    }
    
    func start() {
        if let url = self.url,
            let key =  self.key{
                CJImageCache.sharedInstance.retrieveImageForKey(key, options:options, completionHandler:{(image:UIImage?, cacheType:CacheType!) -> Void in
                    if image == nil && self.isCancelled == false{
                        self.session = NSURLSession(configuration: self.sessionConfiguration, delegate: self, delegateQueue: nil)
                        self.sessionDataTask = self.session?.dataTaskWithURL(url)
                        if let sessionTask = self.sessionDataTask {
                            sessionTask.resume()
                        }
                        
                    } else {
                        if self.isCancelled == false{
                            dispatch_async(self.ioQueue, { () -> Void in
                                for completionHandler in self.completionHandlers {
                                    completionHandler(image:image, data:self.responseData, error:nil, finished:true)
                                }
                                CJImageFetchManager.sharedInstance.removeOperationForKey(url.absoluteString)
                            })
                        }
                    }
                })
        }
    }
    
    func cancel() {
        isCancelled = false
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
            responseData.appendData(data)
            
            dispatch_async(self.ioQueue, { () -> Void in
                for progressHandler in self.progressHandlers {
                    progressHandler(receivedSize: Int64(self.responseData.length), expectedSize: dataTask.response!.expectedContentLength)
                }
            })
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if let URL = task.originalRequest!.URL where self.isCancelled == false {
            if let error = error {
                dispatch_async(self.ioQueue, { () -> Void in
                    for completionHandler in self.completionHandlers {
                        completionHandler(image:nil, data:nil, error:error, finished:true)
                    }
                    CJImageFetchManager.sharedInstance.removeOperationForKey(URL.absoluteString)
                })
            } else {
                if let image = UIImage(data: self.responseData) {
                    CJImageCache.sharedInstance.storeImage(image, key: self.key!, imageData: nil, cachePolicy:self.options.cachePolicy, completionHandler: {()-> Void in
                        let imageResult = self.shouldDecode ? CJImageUtils.DecodImage(image) :image
                        dispatch_async(self.ioQueue, { () -> Void in
                            for completionHandler in self.completionHandlers {
                                completionHandler(image:imageResult, data:self.responseData, error:nil, finished:true)
                            }
                            CJImageFetchManager.sharedInstance.removeOperationForKey(URL.absoluteString)
                        })
                    })
                    
                } else {
                    // If server response is 304 (Not Modified), inform the callback handler with NotModified error.
                    // It should be handled to get an image from cache, which is response of a manager object.
                    var errorCode = ImageDownloadOperationErrorCode.BadData.rawValue;
                    
                    if let res = task.response as? NSHTTPURLResponse where res.statusCode == 304 {
                        errorCode = ImageDownloadOperationErrorCode.NotModified.rawValue;
                    }
                    
                    dispatch_async(self.ioQueue, { () -> Void in
                        let error =  NSError(domain: self.ImageDownloadOperationErrorDomain, code: errorCode, userInfo: nil)
                        for completionHandler in self.completionHandlers {
                            completionHandler(image: nil, data: nil, error: error, finished:true)
                        }
                        CJImageFetchManager.sharedInstance.removeOperationForKey(URL.absoluteString)
                    })
                }
            }
        }
    }
    
}
