//
//  CJImageDownloadOperation.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 9/22/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

public enum ImageDownloadOperationErrorCode: Int {
    case BadData = 10000
    case NotModified = 10001
    case InvalidURL = 20000
}

class CJImageDownloadOperation: NSObject, NSURLSessionTaskDelegate, CJImageRetrievalOperationProtocol{
    
    let ImageDownloadOperationErrorDomain = "com.jiecao.CJImageDownloaderOperation.Error"
    
    var responseData:NSMutableData = NSMutableData()
    var isCancelled:Bool = false
    var sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    var session:NSURLSession?
    var sessionDataTask:NSURLSessionDataTask?
    var progressBlock:((receivedSize:Int64, expectedSize:Int64)->Void)?
    var completionBlock:((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)?
    var shouldDecode:Bool = false
    var url:NSURL?
    var key:String?
    
    init(url:NSURL, shouldDecode:Bool = true, progressBlock:((receivedSize:Int64, expectedSize:Int64)->Void)?, completionBlock:((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)?)
    {
        self.url = url
        self.key = CJImageUtilsManager.defaultKeyConverter(url)
        self.progressBlock = progressBlock
        self.completionBlock = completionBlock
        self.shouldDecode = shouldDecode
    }
    
    func start() {
        if let url = self.url,
            let key =  self.key{
                let options = CJImageUtilsManagerOptions()
                CJImageCache.sharedInstance.retrieveImageForKey(key, options: options, completionHandler:{(image:UIImage?, cacheType:CacheType!) -> Void in
                    if image == nil && self.isCancelled == false{
                        self.session = NSURLSession(configuration: self.sessionConfiguration, delegate: self, delegateQueue: nil)
                        self.sessionDataTask = self.session?.dataTaskWithURL(url)
                        if let sessionTask = self.sessionDataTask {
                            sessionTask.resume()
                        }
                        
                    } else {
                        if let completionCallback = self.completionBlock {
                            completionCallback(image:image, data:self.responseData, error:nil, finished:true)
                        }
                    }
                })
        }
    }
    
    func cancel() {
        isCancelled = false
    }
    
    /**
    This method is exposed since the compiler requests. Do not call it.
    */
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    /**
    This method is exposed since the compiler requests. Do not call it.
    */
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        if let URL = dataTask.originalRequest.URL{
            responseData.appendData(data)
            if let progressCallback = self.progressBlock{
                progressCallback(receivedSize: Int64(responseData.length), expectedSize: dataTask.response!.expectedContentLength)
            }
        }
    }
    
    /**
    This method is exposed since the compiler requests. Do not call it.
    */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if let URL = task.originalRequest.URL {
            if let error = error,
                let completionCallback = self.completionBlock {
                    completionCallback(image: nil, data: nil, error: error, finished: true)
            } else {
                //Download finished without error
                // We are on main queue when receiving this.
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    
                    if let image = UIImage(data: self.responseData) {
                        CJImageCache.sharedInstance.storeImage(image, key: self.key!, imageData: nil, toFile: true, toMemoryCache: false, completionHandler: {()-> Void in
                            if let completionCallback = self.completionBlock {
                                let imageResult = self.shouldDecode ? CJImageUtils.DecodImage(image) :image
                                completionCallback(image: imageResult, data:self.responseData, error:nil, finished:true)
                            }
                        })
                        
                    } else {
                        // If server response is 304 (Not Modified), inform the callback handler with NotModified error.
                        // It should be handled to get an image from cache, which is response of a manager object.
                        var errorCode = ImageDownloadOperationErrorCode.BadData.rawValue;
                        
                        if let res = task.response as? NSHTTPURLResponse where res.statusCode == 304 {
                            errorCode = ImageDownloadOperationErrorCode.NotModified.rawValue;
                        }
                        
                        if let completionCallback = self.completionBlock {
                            
                            let error =  NSError(domain: self.ImageDownloadOperationErrorDomain, code: errorCode, userInfo: nil)
                            completionCallback(image: nil, data: nil, error: error, finished:true)
                        }
                    }
                })
            }
        }
    }
    
}
