//
//  CJImageUtils.swift
//  CJImageUtilsDemo
//
//  Created by Jie Cao on 9/22/15.
//  Copyright (c) 2015 JieCao. All rights reserved.
//

import UIKit

class CJImageUtils: NSObject {
    private static let kPNGHeader: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    private static let kPNGHeaderData:NSData = NSData(bytes: kPNGHeader, length: 8)
    class func isPNG(image:UIImage, imageData:NSData? = nil) -> Bool {
        
        let alphaInfo = CGImageGetAlphaInfo(image.CGImage)
        let hasAlpha:Bool = !(alphaInfo == CGImageAlphaInfo.None ||
            alphaInfo == CGImageAlphaInfo.NoneSkipFirst ||
            alphaInfo == CGImageAlphaInfo.NoneSkipFirst)
        
        var imageIsPNG = hasAlpha
        
        if let data = imageData {
            if (data.length >= kPNGHeaderData.length) {
                if data.subdataWithRange(NSMakeRange(0, kPNGHeaderData.length)) == kPNGHeaderData {
                    imageIsPNG = true
                }
            }
            else {
                imageIsPNG = false
            }
        }
        
        return imageIsPNG
    }


    class func DecodImage(image:UIImage) -> UIImage? {
        return DecodImage(image, scale: image.scale)
    }
    
    class func DecodImage(image:UIImage, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let decodedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return decodedImage
    }
}
