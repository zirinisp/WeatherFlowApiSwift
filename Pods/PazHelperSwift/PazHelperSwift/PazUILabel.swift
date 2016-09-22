//
//  PazUILabel.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 31/03/2015.
//  Copyright (c) 2015 paz-labs. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    public func moveNextToLabel(label: UILabel) {
        self.frame = CGRect(x: label.endTextPoint.cgFloat(), y: label.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height);
    }
    
    public var endTextPoint: Double {
        var width = 0.0
        if let text = self.text {
            width = (text as NSString).size(attributes: [NSFontAttributeName: self.font]).width.toDouble
        }
        return self.frame.origin.x + width
    }
    
    public var fontSize: Double {
        get {
            return self.font.pointSize.toDouble
        }
        set {
            self.font = self.font.withSize(newValue.toCGFloat)
        }
    }
    
    public var vertical: Bool {
        let vertical =
            (self.transform == CGAffineTransform(rotationAngle: ( -90 * M_PI ) / 180)) ||
            (self.transform == CGAffineTransform(rotationAngle: ( 90 * M_PI ) / 180))
        return vertical
    }
    
    public func fontSizeToFit(string: String, font: UIFont) -> Double {
        let size = self.vertical ? CGSize(width: self.height, height: self.width) : self.frame.size
        return UILabel.fontSizeToFit(string: string, font: font, size: size)
    }

    public class func fontSizeToFit(string: String, font: UIFont, size: CGSize) -> Double {
        let maxFont = font.withSize(size.height)
        let fontSize = (string as NSString).size(attributes: [NSFontAttributeName:maxFont])
        if fontSize.height > size.height || fontSize.width > size.width {
            let ratio = MIN(size.width / fontSize.width, size.height / fontSize.height)
            return fontSize.height.doubleValue() * ratio * 0.8
        } else {
            return fontSize.height.doubleValue() * 0.8
        }
    }

    public func adjustFontSizeToFit(string: String, font: UIFont) {
        self.fontSize = self.fontSizeToFit(string: string, font: font)
    }

    public func adjustFontSizeToFit(string: String) {
        self.adjustFontSizeToFit(string: string, font: self.font)
    }

    public func adjustFontSizeToFit() {
        if let text = self.text {
            self.adjustFontSizeToFit(string: text, font: self.font)
        }
    }

    public func fontSizeToFit() -> Double? {
        if let text = self.text {
            return self.fontSizeToFit(string: text, font: self.font)
        }
        return nil
    }
    
    public static func equalFontSizeThatFits(_ labels: [UILabel]) -> Double? {
        var fontSize: Double? = nil
        for label in labels {
            if let labelSize = label.fontSizeToFit() {
                if let previousSize = fontSize {
                    if previousSize > labelSize {
                        fontSize = labelSize
                    }
                } else {
                    fontSize = labelSize
                }
            }
        }
        return fontSize
    }
    
    public static func adjustEqualFontSizeThatFits(labels: [UILabel]) {
        if let fontSize = UILabel.equalFontSizeThatFits(labels) {
            for label in labels {
                label.fontSize = fontSize
            }
        }
    }
}

public extension UIFont {
    func fontSizeToFitHeight(_ height: CGFloat) -> CGFloat {
        let testString: NSString = "TtGgJjXp"
        let sizeToFit = testString.size(attributes: [NSFontAttributeName:self])
        let heightToFit = sizeToFit.height
        let pointPerPixel = self.pointSize / heightToFit
        let desiredHeight = height * pointPerPixel
        return desiredHeight
    }
}

public class PazUIFitLabel: UILabel {
    
    public init(desiredFont: UIFont, desiredTextToFit: String? = nil) {
        self.desiredFont = desiredFont
        self.desiredTextToFit = desiredTextToFit
        super.init(frame: CGRect.zero)
    }

    public init(textStyle: UIFontTextStyle, desiredTextToFit: String? = nil) {
        self.desiredFont = textStyle.font
        self.textStyle = textStyle
        self.desiredTextToFit = desiredTextToFit
        super.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var textStyle: UIFontTextStyle? {
        didSet {
            if let font = self.textStyle?.font {
                self.desiredFont = font
            }
        }
    }
    
    /// This is the font that we would like to use. The label will use this font size only if the desiredTextToFit fits. If not it will use a smaller font.
    public var desiredFont: UIFont {
        didSet {
            self.updateFont()
        }
    }
    
    /// Text that we want to make sure it fits (width and height). If not we will decrease font size to make it fit
    public var desiredTextToFit: String? {
        didSet {
            if oldValue == self.desiredTextToFit {
                return
            }
            self.updateFont()
        }
    }
    
    public override var frame: CGRect {
        didSet {
            if oldValue == self.frame {
                return
            }
            self.updateFont()
        }
    }
    
    public var adjustsFontSizeToFitHeight: Bool = true {
        didSet {
            if oldValue == self.adjustsFontSizeToFitHeight {
                return
            }
            self.updateFont()
        }
    }
    
    func updateFont() {
        defer {
            self.adjustFontSizeToFitHeight()
        }
        guard let desiredText = self.desiredTextToFit else {
            self.font = self.desiredFont
            return
        }
        let sizeThatFits = self.fontSizeToFit(string: desiredText, font: self.desiredFont)
        let desiredSize = self.desiredFont.pointSize
        if sizeThatFits < desiredSize {
            self.font = self.desiredFont.withSize(sizeThatFits.cgFloat())
        } else {
            self.font = self.desiredFont
        }
    }
    
    func adjustFontSizeToFitHeight() {
        guard self.adjustsFontSizeToFitHeight else {
            return
        }
        let labelHeight: CGFloat = self.vertical ? self.width.cgFloat() : self.height.cgFloat()
        let sizeThatFits = self.font.fontSizeToFitHeight(labelHeight)
        let currentSize = self.font.pointSize
        if sizeThatFits < currentSize {
            self.font = self.font.withSize(sizeThatFits)
        }
    }
    
    public var adjustedFont: Bool {
        return self.desiredFont.pointSize != self.font.pointSize
    }
    
    public override func fontSizeToFit(string: String, font: UIFont) -> Double {
        let size = self.vertical ? CGSize(width: self.height, height: self.width) : self.frame.size
        var fontSize = UILabel.fontSizeToFit(string: string, font: font, size: size)
        if let desiredTextToFit = self.desiredTextToFit {
            let desiredFontSize = UILabel.fontSizeToFit(string: desiredTextToFit, font: self.desiredFont, size: size)
            fontSize = MIN(fontSize, desiredFontSize)
        }
        return fontSize
    }

    
}

