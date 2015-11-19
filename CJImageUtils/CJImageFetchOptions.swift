//
//  CJImageFetchOptions.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 6/13/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

enum CJImageDownloadPriority {

    case DefaultPriority
    case LowPriority
    case HighPriority

}

enum CJImageCachePolicy:Int {
    case NoCache = 0
    case MemoryCache = 1
    case FileCache = 2
    case MemoryAndFileCache = 3
}


class CJImageFetchOptions: NSObject {
    var priority:CJImageDownloadPriority = .DefaultPriority
    var cachePolicy:CJImageCachePolicy = .MemoryAndFileCache
    var shouldDecode: Bool = true
    var requestCachePolicy : NSURLRequestCachePolicy = .UseProtocolCachePolicy;
    var scale: CGFloat = UIScreen.mainScreen().scale
}
