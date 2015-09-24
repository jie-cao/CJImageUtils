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
    * By default, when a URL fail to be downloaded, the URL is blacklisted so the library won't keep trying.
    * This flag disable this blacklisting.
    */
    case SDWebImageRetryFailed
    
    /**
    * By default, image downloads are started during UI interactions, this flags disable this feature,
    * leading to delayed download on UIScrollView deceleration for instance.
    */
    case SDWebImageLowPriority
    
    /**
    * This flag disables on-disk caching
    */
    case SDWebImageCacheMemoryOnly
    
    /**
    * This flag enables progressive download, the image is displayed progressively during download as a browser would do.
    * By default, the image is only displayed once completely downloaded.
    */
    case SDWebImageProgressiveDownload
    
    /**
    * Even if the image is cached, respect the HTTP response cache control, and refresh the image from remote location if needed.
    * The disk caching will be handled by NSURLCache instead of SDWebImage leading to slight performance degradation.
    * This option helps deal with images changing behind the same request URL, e.g. Facebook graph api profile pics.
    * If a cached image is refreshed, the completion block is called once with the cached image and again with the final image.
    *
    * Use this flag only if you can't make your URLs static with embedded cache busting parameter.
    */
    case SDWebImageRefreshCached
}

protocol CJImageRetrievalOperationProtocol {
    func cancel()
}

class CJImageUtilsManager: NSObject {

    static let sharedInstance = CJImageUtilsManager()

    class func defaultKeyConverter(urlString:NSURL)->String?{
        return urlString.absoluteString
    }
    
    func retrieveImageFromUrl(url:NSURL, option:CJImageOptions, completionBlock:((image:UIImage?, data:NSData?, error:NSError?, finished:Bool)->Void)?, progressBlock:((receivedSize:Int64, expectedSize:Int64)->Void)?){
        var imageFetchOperation = CJImageDownloadOperation(url: url, shouldDecode: true, progressBlock: progressBlock, completionBlock: completionBlock)
        imageFetchOperation.start()
    }
}
