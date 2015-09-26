//
//  CJImageUtilsManagerOptions.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 9/22/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

enum CJImageDownloadPriority {
    
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

}

enum CJImageCachePolicy {
    
    /**
    * This flag disables on-disk caching
    */
    case CJImageOptionMemoryAndFileCache

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


class CJImageFetchOptions: NSObject {
    var priority:CJImageDownloadPriority = .CJImageOptionDefaultPriority
    var cachePolicy:CJImageCachePolicy = .CJImageOptionMemoryAndFileCache
    var shouldDecode: Bool = false
    var scale: CGFloat = UIScreen.mainScreen().scale
}
