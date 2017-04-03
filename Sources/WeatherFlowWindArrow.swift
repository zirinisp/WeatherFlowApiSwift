//
//  WeatherFlowWindArrow.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 07/10/2016.
//  Copyright © 2016 Pantelis Zirinis. All rights reserved.
//


// File contains libraries that refer to UIKit, so building on Mac is exluded.
#if !os(OSX) && !os(Linux)

import Foundation
import UIKit


extension WeatherFlowApiSwift {
    // MARK: - Graphics
    // TODO: Improve swift use
    static var arrowCache = [WeatherFlowArrowImage]()
    
    class func windArrowWithSize(_ size: Float) -> UIImage {
        let arrow: UIImage = self.windArrowWithSize(size, fillColor: UIColor.gray, strokeColor: UIColor.gray)
        return arrow
    }
    
    class func windArrowWithSize(_ size: Float, fillColor: UIColor, strokeColor: UIColor) -> UIImage {
        //Check for ready image in cache
        var cache = self.arrowCache.filter { (image) -> Bool in
            return image.fillColor == fillColor && image.strokeColor == strokeColor && image.size == Int(size)
        }
        
        if cache.count != 0 {
            let image = cache[0].image
            return image.copy() as! UIImage
        }
        NSLog("No cahce for size %f", size)
        // Get a bigger image for quality reasons
        let width: CGFloat = CGFloat(size)
        let height: CGFloat = CGFloat(size)
        // Prepare Points
        let arrowWidth: CGFloat = 0.5 * width
        let buttonLeftPoint: CGPoint = CGPoint(x: (width - arrowWidth) / 2.0, y: height * 0.9)
        let buttonRightPoint: CGPoint = CGPoint(x: buttonLeftPoint.x + arrowWidth, y: height * 0.9)
        let topArrowPoint: CGPoint = CGPoint(x: width / 2.0, y: 0.0)
        let buttomMiddlePoint: CGPoint = CGPoint(x: width / 2.0, y: 0.7 * height)
        // Start Context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        // Prepare context parameters
        context.setLineWidth(1)
        context.setStrokeColor(strokeColor.cgColor)
        context.setFillColor(fillColor.cgColor)
        let pathRef: CGMutablePath = CGMutablePath()
        pathRef.move(to: CGPoint(x: topArrowPoint.x, y: topArrowPoint.y))
        pathRef.addLine(to: CGPoint(x: buttonLeftPoint.x, y: buttonLeftPoint.y))
        pathRef.addLine(to: CGPoint(x: buttomMiddlePoint.x, y: buttomMiddlePoint.y))
        pathRef.addLine(to: CGPoint(x: buttonRightPoint.x, y: buttonRightPoint.y))
        pathRef.addLine(to: CGPoint(x: topArrowPoint.x, y: topArrowPoint.y))
        pathRef.closeSubpath()
        context.addPath(pathRef)
        context.fillPath()
        context.addPath(pathRef)
        context.strokePath()
        let i: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // Resize image.
        let newImage = WeatherFlowArrowImage(fillColor: fillColor, strokeColor: strokeColor, size: Int(size), image: i.copy() as! UIImage)
        self.arrowCache.append(newImage)
        return i
    }
    
    class func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        if image.size.equalTo(size) {
            return image
        }
        NSLog("Resize")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: size.height), false, 0.0)
        // Set the quality level to use when rescaling
        //CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func windArrowWithSize(_ size: Float, degrees: Float, fillColor: UIColor, strokeColor: UIColor, text: String) -> UIImage {
        let image: UIImage = self.windArrowWithSize(size, fillColor: fillColor, strokeColor: strokeColor)
        let i: UIImage = self.rotatedImage(image, degrees: degrees)
        // Resize
        //i = [self resizeImage:i to:CGSizeMake(size, size)];
        // Add Text
        return self.addText(text, toImage: i)
    }
    
    class func windArrowWithText(_ text: String, degrees: Float) -> UIImage {
        let image: UIImage = self.windArrowWithSize(30.0)
        let i: UIImage = self.rotatedImage(image, degrees: degrees)
        // Add Text
        return self.addText(text, toImage: i)
    }
    
    class func waveArrowWithText(_ text: String, degrees: Float) -> UIImage {
        let image: UIImage = self.windArrowWithSize(30, fillColor: UIColor.blue, strokeColor: UIColor.blue)
        // Create image
        let i: UIImage = self.rotatedImage(image, degrees: degrees)
        return self.addText(text, toImage: i)
    }
    
    class func addText(_ text: String?, toImage image: UIImage) -> UIImage {
        guard let text = text , text.characters.count != 0 else {
            return image
        }
        let font: UIFont = UIFont.boldSystemFont(ofSize: 14.0)
        let constrainSize: CGSize = CGSize(width: 30, height: image.size.height)
        let string = text as NSString
        var stringSize: CGSize = string.size(attributes: [NSFontAttributeName: font])
        stringSize = CGSize(width: min(constrainSize.width, stringSize.width), height: min(constrainSize.height, stringSize.height))
        let size: CGSize = CGSize(width: image.size.width + stringSize.width, height: max(image.size.height, stringSize.height))
        UIGraphicsBeginImageContext(size)
        // Draw image
        UIGraphicsGetCurrentContext()?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        // Draw Text
        UIGraphicsGetCurrentContext()?.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let renderingRect: CGRect = CGRect(x: image.size.width, y: 0, width: stringSize.width, height: stringSize.height)
        
        /// Make a copy of the default paragraph style
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        /// Set line break mode
        paragraphStyle.lineBreakMode = NSLineBreakMode.byCharWrapping
        /// Set text alignment
        paragraphStyle.alignment = NSTextAlignment.left
        
        let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle] as [String : Any]
        
        string.draw(in: renderingRect, withAttributes: attributes)
        
        let i: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return i
    }
    
    class func rotatedImage(_ image: UIImage, degrees: Float) -> UIImage {
        // We add 180 to callibrate the arrow and then conver to radians.
        let rads: CGFloat = CGFloat(degrees) * CGFloat(Double.pi / 180.0)
        let newSide: CGFloat = max(image.size.width, image.size.height)
        // Start Context
        let size: CGSize = CGSize(width: newSide, height: newSide)
        UIGraphicsBeginImageContext(size)
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.translateBy(x: newSide / 2, y: newSide / 2)
        ctx.rotate(by: rads)
        UIGraphicsGetCurrentContext()?.draw(image.cgImage!, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: size.width, height: size.height))
        // Create image
        let i: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return i
    }
}


struct WeatherFlowArrowImage {
    var fillColor: UIColor
    var strokeColor: UIColor
    var size: Int
    var image: UIImage
}

#endif
