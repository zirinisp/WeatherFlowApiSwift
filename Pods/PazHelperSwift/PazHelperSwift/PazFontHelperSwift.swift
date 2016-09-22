//
//  PazFontHelperSwift.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 12/05/2015.
//  Copyright (c) 2015 paz-labs. All rights reserved.
//

import UIKit

public class PazFontHelperSwift: UIFont {
    public static var shared = PazFontHelperSwift()
    
    public var systemFont: String = "HelveticaNeue"
    public var boldSystemFont = "HelveticaNeue-Bold"
    
    public func systemFontOfSize(_ size: Double) -> UIFont {
        if let font = UIFont(name: self.systemFont, size: size.cgFloat()) {
            return font
        } else {
            return self.systemFontOfSize(size)
        }
    }

    public func boldSystemFontOfSize(_ size: Double) -> UIFont {
        if let font = UIFont(name: self.boldSystemFont, size: size.cgFloat()) {
            return font
        } else {
            return self.boldSystemFontOfSize(size)
        }
    }

    public var titleSystemFontSize = 18.0
    public var titleSystemFont: UIFont {
        return self.systemFontOfSize(self.titleSystemFontSize)
    }
    
    public var subtitleSystemFontSize = 18.0
    public var subtitleSystemFont: UIFont {
        return self.systemFontOfSize(self.subtitleSystemFontSize)
    }

}

/* Swift 3 Makes it obsolete
public enum TextStyle {
    case Headline
    case Body
    case Subheadline
    case Footnote
    case Caption1
    case Caption2
    
    public init?(font: UIFont) {
        let styles = [ UIFontTextStyle.headline, UIFontTextStyle.body, UIFontTextStyle.subheadline, UIFontTextStyle.footnote, UIFontTextStyle.caption1, UIFontTextStyle.caption2 ]
        
        var nativeStyle: String?
        for style in styles {
            if font == UIFont.preferredFont(forTextStyle: style) {
                nativeStyle = style.rawValue
                break
            }
        }
        
        if let style = nativeStyle {
            self.init(string: style)
        } else {
            return nil
        }
    }
    
    public init!(string: String) {
        switch string {
        case UIFontTextStyleHeadline: self = .Headline
        case UIFontTextStyleBody: self = .Body
        case UIFontTextStyleSubheadline: self = .Subheadline
        case UIFontTextStyleFootnote: self = .Footnote
        case UIFontTextStyleCaption1: self = .Caption1
        case UIFontTextStyleCaption2: self = .Caption2
        default: return nil
        }
    }
    
    public var stringValue: String {
        switch self {
        case .Headline: return UIFontTextStyle.headline.rawValue
        case .Body: return UIFontTextStyle.body.rawValue
        case .Subheadline: return UIFontTextStyle.subheadline.rawValue
        case .Footnote: return UIFontTextStyle.footnote.rawValue
        case .Caption1: return UIFontTextStyle.caption1.rawValue
        case .Caption2: return UIFontTextStyle.caption2.rawValue
        }
    }
    
    public var font: UIFont {
        return UIFont.preferredFont(forTextStyle: UIFontTextStyle(rawValue: self.stringValue))
    }
    
}
*/

extension UIFontTextStyle {
    
    public var font: UIFont {
        return UIFont.preferredFont(forTextStyle: self)
    }
    
}
