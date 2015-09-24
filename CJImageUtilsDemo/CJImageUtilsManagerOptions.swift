//
//  CJImageUtilsManagerOptions.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 9/22/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

class CJImageUtilsManagerOptions: NSObject {
   var forceRefresh: Bool = false
    var lowPriority: Bool = false
    var cacheMemoryOnly: Bool = false
    var shouldDecode: Bool = false
    var queue: dispatch_queue_t!
    var scale: CGFloat = 1.0
    
}
