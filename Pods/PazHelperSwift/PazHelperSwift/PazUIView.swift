//
//  PazUIView.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 31/03/2015.
//  Copyright (c) 2015 paz-labs. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    public func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subView in self.subviews {
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil;
    }
    
    public func findAndResignFirstResponder() -> Bool {
        if let firstResponder = self.findFirstResponder() {
            return firstResponder.resignFirstResponder()
        }
        return false
    }
    
    public func addSubviews(_ subviews: [UIView]) {
        for view in subviews {
            self.addSubview(view)
        }
    }
    
    public func screenshot() -> UIImage {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return capturedImage!;
        } else {
            return UIImage()
        }
    }
    
    public func saveScreenshotToPhotosAlbum() {
        UIImageWriteToSavedPhotosAlbum(self.screenshot(), nil, nil, nil)
    }
    
    public class func setAlpha(alpha: Double, forViews: Array<UIView>) {
        for view in forViews {
            view.alpha = alpha.cgFloat()
        }
    }
    
    public class func setHidden(hidden: Bool, forViews: Array<UIView>) {
        for view in forViews {
            view.isHidden = hidden
        }
    }
    
    public var viewController: UIViewController? {
        // convenience function for casting and to "mask" the recursive function
        return self.traverseResponderChainForUIViewController()
    }
    
    func traverseResponderChainForUIViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        }
        if let nextResponder = self.next as? UIView {
            return nextResponder.traverseResponderChainForUIViewController()
        }
        return nil
    }
    
    public var x: Double {
        return self.frame.origin.x.toDouble
    }
    
    public var y: Double {
        return self.frame.origin.y.toDouble
    }
    
    public var width: Double {
        return self.frame.size.width.toDouble
    }
    
    public var height: Double {
        return self.frame.size.height.toDouble
    }
    
    public var xEnd: Double {
        return self.x + self.width
    }
    public var yEnd: Double {
        return self.y + self.height
    }
    
    public func horizontalCenterOn(_ view: UIView) {
        var frame = self.frame;
        frame.origin.x = (view.frame.size.width - frame.size.width) / 2.0;
        self.frame = frame;
    }
    
    public func verticalCenterOn(_ view: UIView) {
        var frame = self.frame;
        frame.origin.y = (view.frame.size.height - frame.size.height) / 2.0;
        self.frame = frame;
    }
    
    public func centerOn(_ view: UIView) {
        var frame = self.frame;
        frame.origin.x = (view.frame.size.width - frame.size.width) / 2.0;
        frame.origin.y = (view.frame.size.height - frame.size.height) / 2.0;
        self.frame = frame;
    }
    
}
