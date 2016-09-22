//
//  PazExtensions.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 21/10/2014.
//  Copyright (c) 2014 paz-labs. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreLocation
import UIKit

public func IsLandscape() -> Bool {
    return UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
}

public func IsPortrait() -> Bool {
    return UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
}

public func executeMainWithDelay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { 
        closure()
    }
}

public func executeMain(_ closure:@escaping ()->()) {
    DispatchQueue.main.async {
        closure()
    }
}

@available(iOS 8.0, *)
public func executeBackground(_ closure:@escaping ()->()) {
    let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    backgroundQueue.async {
        closure()
    }
}

@available(iOS 8.0, *)
public func executeBackgroundWithdelay(_ delay:Double, closure:@escaping ()->()) {
    let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    backgroundQueue.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

public func DegreesToRadians (_ degrees: Double) -> Double {
    let radians = ((M_PI * degrees) / 180.0)
    return radians
}


public func RadiansToDegrees (_ rad: Double) -> Double {
    let degrees = ((180.0 * rad) / M_PI)
    return degrees
}

public func SQR(_ x: Double) -> Double {
    let sqr = x * x
    return sqr
}

public func MIN<T : Comparable>(_ a: T, _ b: T) -> T {
    if a > b {
        return b
    }
    return a
}

public func MAX<T : Comparable>(_ a: T, _ b: T) -> T {
    if a > b {
        return a
    }
    return b
}

// if value between min and max returns value. Otherwise min or max.
public func MINMAX<T : Comparable>(_ value: T, min: T, max: T) -> T {
    if value < min {
        return min
    }
    if value > max {
        return max
    }
    return value
}


public func isIOS7() -> Bool {
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1
}

public func isIOS8() -> Bool {
    return UIDevice.current.systemVersion.toDouble() ?? 0.0 >= 8.0
}

public extension Bundle {
    public var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    public var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
}

public func PazCGPointOffset(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
    return CGPoint(x: point2.x - point1.x, y: point2.y - point1.y)
}

public func PazCGPointDistance(_ point1: CGPoint, _ point2: CGPoint) ->  Double {
    return sqrt( pow(point2.x.doubleValue() - point1.x.doubleValue(), 2.0) + pow(point2.y.doubleValue() - point1.y.doubleValue(), 2.0))
}

public func Rgb2UIColor(r: ScalarCGFloatType, g: ScalarCGFloatType, b: ScalarCGFloatType, a: ScalarCGFloatType) -> UIColor {
    return UIColor(red: r.toCGFloat / 255.0, green: g.toCGFloat / 255.0, blue: b.toCGFloat / 255.0, alpha: a.toCGFloat)
}

public func IntOrZero(_ number: Int?) -> Int {
    if let int = number {
        return int
    }
    return 0
}

public func DoubleOrZero(_ number: Double?) -> Double {
    if let double = number {
        if double.isNaN {
            return 0.0
        }
        return double
    }
    return 0.0
}
public func DoubleOrZero(_ number: ScalarFloatingPointType?) -> Double {
    if let double = number?.toDouble {
        return double
    }
    return 0.0
}

public func BoolOrFalse(_ bool: Bool?) -> Bool {
    if let letBool = bool {
        return letBool
    }
    return false
}

public func BoolOrTrue(_ bool: Bool?) -> Bool {
    if let letBool = bool {
        return letBool
    }
    return true
}

public func RectOrZero(_ rect: CGRect?) -> CGRect {
    if let letRect = rect {
        return letRect
    }
    else {
        return CGRect.zero
    }
}

public func StringOrEmpty(_ string: String?) -> String {
    if let letString = string {
        return letString
    }
    return ""
}

public struct PazKeyboardNotification {
    public init(fromNotification notification: Notification) {
        if let userInfo = notification.userInfo as? Dictionary<String, AnyObject> {
            if let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
                self.frameBegin = keyboardFrame.cgRectValue
            }
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                self.frameEnd = keyboardFrame.cgRectValue
            }
            if let animationCurveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                if let animationCurve = UIViewAnimationCurve(rawValue: animationCurveNumber.intValue) {
                    self.animationCurve = animationCurve
                }
            }
            if let animationDuration = userInfo[String(UIKeyboardAnimationDurationUserInfoKey)] as? NSNumber {
                self.animationDuration = animationDuration.doubleValue
            }
        }
    }
    public var frameBegin: CGRect?
    public var frameEnd: CGRect?
    public var animationCurve: UIViewAnimationCurve?
    public var animationDuration: TimeInterval?
}

public extension Character {
    
    /**
    If the character represents an integer that fits into an Int, returns
    the corresponding integer.
    */
    public func toInt () -> Int? {
        return Int(String(self))
    }
    
}

public extension NSArray {
    
    /**
    Converts an NSArray object to an OutType[] array containing the items in the NSArray of type OutType.
    
    - returns: Array of Swift objects
    */
    func cast <OutType> () -> [OutType] {
        var result = [OutType]()
        
        for item : Any in self {
            result += ExSwift.bridgeObjCObject(item) as [OutType]
        }
        
        return result
    }
    
    /**
    Flattens a multidimensional NSArray to an OutType[] array
    containing the items in the NSArray that can be bridged from their ObjC type to OutType.
    
    - returns: Flattened array
    */
    public func flatten <OutType> () -> [OutType] {
        var result = [OutType]()
        let ref = Mirror(reflecting: self)
        for child in ref.children {
            guard let _ = child.label else {
                continue
            }
            let value = child.value
            result += ExSwift.bridgeObjCObject(value) as [OutType]
        }
        
        /*
        let reflection = reflect(self)
        
        for i in 0..<reflection.count {
        result += ExSwift.bridgeObjCObject(reflection[i].1.value) as [OutType]
        }*/
        
        return result
    }
    
    /**
    Flattens a multidimensional NSArray to a [AnyObject].
    
    - returns: Flattened array
    */
    public func flattenAny () -> [AnyObject] {
        var result = [AnyObject]()
        
        for item in self {
            if let array = item as? NSArray {
                result += array.flattenAny()
            } else {
                result.append(item as AnyObject)
            }
        }
        
        return result
    }
    
}

public extension CALayer {
    public func bringSublayerToFront(layer: CALayer) {
        if let superlayer = layer.superlayer {
            if (superlayer.sublayers?.count ?? 0) <= 1 {
                // Only one sublayer so it is in front
                return
            }
            
            layer.removeFromSuperlayer()
            let index: UInt32 = UInt32((superlayer.sublayers?.count ?? 0))
            superlayer.insertSublayer(layer, at: index)
        }
    }
    
    public func sendSublayerToBack(layer: CALayer) {
        if let superlayer = layer.superlayer {
            layer.removeFromSuperlayer()
            superlayer.insertSublayer(layer, at:0)
        }
    }
}

public extension CGRect {
    public func rectWithInsets (_ insets: UIEdgeInsets) -> CGRect {
        let dWidth: CGFloat = MIN(self.width, insets.left + insets.right)
        let dHeight: CGFloat = MIN(self.height, insets.top + insets.bottom)
        let dX: CGFloat = MIN(self.width, insets.left)
        let dY: CGFloat = MIN(self.height, insets.top)
        
        return CGRect(x: self.origin.x + dX, y: self.origin.y + dY, width: self.size.width - dWidth, height: self.size.height - dHeight)
    }
    
    public func rectWithInset (_ inset: Double) -> CGRect {
        let insets = UIEdgeInsets(top: inset.cgFloat(), left: inset.cgFloat(), bottom: inset.cgFloat(), right: inset.cgFloat())
        return self.rectWithInsets(insets)
    }

    public func rectWithInsetPercent (_ percent: Double) -> CGRect {
        let actualPercent: CGFloat = MIN(0.5, percent.cgFloat())
        let verticalInsets: CGFloat = self.size.height * actualPercent
        let horizontalInsets: CGFloat = self.size.width * actualPercent
        let insets = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        return self.rectWithInsets(insets)
    }

    public func rectWithInsetPercent (_ percentX: Double, percentY: Double) -> CGRect {
        let actualPercentX: CGFloat = MIN(0.5, percentX.cgFloat())
        let actualPercentY: CGFloat = MIN(0.5, percentY.cgFloat())
        let verticalInsets: CGFloat = self.size.height * actualPercentY
        let horizontalInsets: CGFloat = self.size.width * actualPercentX
        let insets = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        return self.rectWithInsets(insets)
    }
    
    public func rectWithAspectRatio(_ aspectRatio: Double) -> CGRect {
        let currentRatio: Double = self.size.width.doubleValue() / self.size.height.doubleValue()
        if currentRatio == aspectRatio {
            return self
        }
        var newFrame = self
        if currentRatio < aspectRatio {
            let height = self.size.width.doubleValue() / aspectRatio
            let dy = (self.size.height - height) / 2.0
            newFrame.size.height = height.cgFloat()
            newFrame.origin.y += dy
        } else {
            let width = self.size.height.doubleValue() * aspectRatio
            let dx = (self.size.width - width) / 2.0
            newFrame.size.width = width.cgFloat()
            newFrame.origin.x += dx
        }
        return newFrame
    }

    public var xEnd: CGFloat {
        get {
            return self.origin.x + self.size.width
        }
        set {
            self.origin.x = newValue - self.size.width
        }
    }
    
    public var yEnd: CGFloat {
        get {
            return self.origin.y + self.size.height
        }
        set {
            self.origin.y = newValue - self.size.height
        }
    }
    
    public var center: CGPoint {
        get {
            return CGPoint(x: self.xCenter, y: self.yCenter)
        }
        set {
            self.xCenter = newValue.x
            self.yCenter = newValue.y
        }
    }
    
    public var xCenter: CGFloat {
        get {
            return self.origin.x + (self.size.width / 2.0)
        }
        set {
            self.origin.x = newValue - (self.size.width / 2.0)
        }
    }
    
    public var yCenter: CGFloat {
        get {
            return self.origin.y + (self.size.height / 2.0)
        }
        set {
            self.origin.y = newValue - (self.size.height / 2.0)
        }
    }
    
    var centeredSquareRect: CGRect {
        let squareSize = MIN(self.width, self.height)
        return CGRect(x: self.origin.x + ((self.width - squareSize) / 2.0), y: self.origin.y + ((self.height - squareSize) / 2.0), width: squareSize, height: squareSize)
    }
}

public extension UIButton {
    func setImageEdgeRatio(ratio: Double?) {
        let ver = CGFloat(self.height * (ratio ?? 0.0))
        let hor = CGFloat(self.width * (ratio ?? 0.0))
        self.imageEdgeInsets = UIEdgeInsets(top: ver, left: hor, bottom: ver, right: hor)
    }
}

public extension UIBarButtonItem {
    
    public convenience init(button: UIButton, target: AnyObject, selector:Selector) {
        button.addTarget(target, action:selector, for:UIControlEvents.touchUpInside)
        button.showsTouchWhenHighlighted = true
        
        self.init(customView: button)
    }
    
    /*
    public convenience init(barButtonItemWithImage image: UIImage, size: CGSize, target: AnyObject, selector:Selector) {
    let frameimg = CGRectMake(0, 0, size.width, size.height);
    var scaledImage = image;
    if CGSizeEqualToSize(size, image.size) == false {
    scaledImage = image.scaledToSizeWithSameAspectRatio(size)
    }
    var someButton = UIButton(frame: frameimg)
    someButton.addTarget(target, action:selector, forControlEvents:UIControlEvents.TouchUpInside)
    someButton.setBackgroundImage(scaledImage, forState:UIControlState.Normal)
    someButton.showsTouchWhenHighlighted = true
    
    self.init(customView: someButton)
    }
    
    public convenience init(barButtonItemWithImage image: UIImage, height: Double, target: AnyObject, selector:Selector) {
    var width = (height / image.size.height) * image.size.width;
    if isnan(width) {
    width = 0.0
    }
    let size = CGSizeMake(width, height);
    self.init(barButtonItemWithImage:image, size:size, target:target, selector:selector)
    }*/
}

public extension CGSize {
    func isValid() -> Bool {
        return !(self.width < 0.1 || self.height < 0.0 || self.width.isNaN || self.height.isNaN)
    }
}

public extension UIImage {
    public func resize(_ size:CGSize, contentMode: UIViewContentMode = UIViewContentMode.scaleToFill) -> UIImage?
    {
        if !self.size.isValid() || !size.isValid() {
            if let data = UIImagePNGRepresentation(self) {
                return UIImage(data: data)
            } else {
                return nil
            }
        }
        let horizontalRatio = size.width / self.size.width;
        let verticalRatio = size.height / self.size.height;
        var ratio: CGFloat!
        
        switch contentMode {
        case .scaleToFill:
            ratio = 1
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            ratio = 1
        }
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width * ratio, height: self.size.height * ratio)
        
        // Fix for a colorspace / transparency issue that affects some types of
        // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        let transform = CGAffineTransform.identity
        
        // Rotate and/or flip the image if required by its orientation
        context.concatenate(transform);
        
        // Set the quality level to use when rescaling
        context.interpolationQuality = CGInterpolationQuality(rawValue: 3)!
        
        
        //CGContextSetInterpolationQuality(context, CGInterpolationQuality(kCGInterpolationHigh.value))
        
        // Draw into the context; this scales the image
        guard let cgImage = self.cgImage else {
            return nil
        }
        context.draw(cgImage, in: rect)
        
        // Get the resized image from the context and a UIImage
        guard let newCgImage = context.makeImage() else {
            return nil
        }
        let newImage = UIImage(cgImage: newCgImage)
        return newImage
    }
    
    public func fillWithColor(_ color: UIColor) -> UIImage? {
        let img = self
        // begin a new image context, to draw our colored image onto
        UIGraphicsBeginImageContextWithOptions(img.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
    
        // get a reference to that context we created
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.interpolationQuality = CGInterpolationQuality.high
    
        // set the fill color
        color.setFill()
    
        // translate/flip the graphics context (for transforming from CG* coords to UI* coords
        context.translateBy(x: 0, y: img.size.height);
        context.scaleBy(x: 1.0, y: -1.0);
    
        // set the blend mode to color burn, and the original image
        context.setBlendMode(CGBlendMode.multiply);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height);
        //CGContextDrawImage(context, rect, img.CGImage);
    
        // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
        context.clip(to: rect, mask: img.cgImage!)
        context.addRect(rect)
        context.drawPath(using: CGPathDrawingMode.fill)
    
    
        // generate a new UIImage from the graphics context we drew onto
        guard let coloredImg = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
    
        //return the color-burned image
        return coloredImg
    }

}


private var correctTableOffsetOnceKey: UInt8 = 0

public extension UITableView {
    public func indexPathForView (view : UIView) -> IndexPath? {
        let location = view.convert(CGPoint.zero, to:self)
        return indexPathForRow(at: location)
    }

    private struct AssociatedKeys {
        static var correctTableOffsetOnceKey = "displayed"
    }
    
    var correctTableOffsetOnceVar : Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.correctTableOffsetOnceKey) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.correctTableOffsetOnceKey,NSNumber(value: value),objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func correctTableOffsetOnce() {
        if self.correctTableOffsetOnceVar {
            return
        }
        
        if self.contentSize.height > (self.frame.size.height - self.contentInset.top) {
            
            let maxOffset: CGFloat = MAX(0.0, self.contentSize.height - self.height)
        
            let offset = MINMAX(self.contentInset.top, min: 0.0, max: maxOffset)
        
            self.setContentOffset(CGPoint(x: 0.0, y: -offset), animated: true)
        }
        self.correctTableOffsetOnceVar = true
    }
    
    public func cellWithIdentifier(identifier: String, style: UITableViewCellStyle = UITableViewCellStyle.default) -> UITableViewCell {
        if let cell = self.dequeueReusableCell(withIdentifier: identifier) {
            return cell
        }
        let cell = UITableViewCell(style: style, reuseIdentifier: identifier)
        return cell
    }
}


public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

public extension UITextView {
    public func updateTextFontToFit() {
        guard let font = self.font , !self.text.isEmpty, !self.bounds.size.equalTo(CGSize.zero) else {
            return
        }
        let textViewSize = self.frame.size;
        let fixedWidth = textViewSize.width;
        let expectSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)));
        
        var expectFont = self.font;
        if (expectSize.height > textViewSize.height) {
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height) {
                expectFont = self.font!.withSize(self.font!.pointSize - 1)
                self.font = expectFont
            }
        }
        else {
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height) {
                expectFont = font
                self.font = font.withSize(self.font!.pointSize + 1)
            }
            self.font = expectFont;
        }
    }
}

public extension UIColor {
    //newColor is the percentage change for each row multiplied by the distance between the two colors
    //this number is subtracted from the starting color piecewise from red, green, and blue values respectively
    public static func colorBetween(startColor: UIColor, endColor: UIColor, percent: Double) -> UIColor {
        let startcomponents = startColor.cgColor.components
        let endcomponents = endColor.cgColor.components
        
        let r = ((startcomponents?[0])! - (endcomponents?[0])!)
        let g = ((startcomponents?[1])! - (endcomponents?[1])!)
        let b = ((startcomponents?[2])! - (endcomponents?[2])!)
        let a = ((startcomponents?[3])! - (endcomponents?[3])!)
        
        let rdelta = (percent.cgFloat() * r)
        let gdelta = (percent.cgFloat() * g)
        let bdelta = (percent.cgFloat() * b)
        let adelta = (percent.cgFloat() * a)
        
        let newColor: UIColor = UIColor(red: fabs(startcomponents![0] - rdelta), green: fabs(startcomponents![1] - gdelta), blue: fabs(startcomponents![2] - bdelta), alpha: fabs(startcomponents![3] - adelta))
        return newColor
    }

}

public class VerticallyCenteredTextView: UITextView {
    override public var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}

struct URLSessionError: Error {
    enum ErrorKind {
        case timeout
    }
    let kind: ErrorKind
    var localizedDescription: String {
        switch self.kind {
        case .timeout:
            return "Timeout Occured"
        }
    }
}

public extension URLSession {
    public func synchronousDataTaskWithURL(_ url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = self.dataTask(with: url as URL, completionHandler: {
            data = $0
            response = $1
            error = $2 as Error?
            sem.signal()
        })
        
        task.resume()
        
        let result = sem.wait(timeout: DispatchTime.distantFuture)
        switch result {
        case .success:
            return (data, response, error)
        case .timedOut:
            let error = URLSessionError(kind: URLSessionError.ErrorKind.timeout)
            return (data, response, error)

        }
    }
}

public extension UICollectionView {
    public var usableWidth: Double {
        return self.width - self.contentInset.left - self.contentInset.right
    }
    
    public var usableHeight: Double {
        return self.height - self.contentInset.top - self.contentInset.bottom
    }

}
