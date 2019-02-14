//
//  String+.swift
//  SwiftExtensions
//
//  Created by Tatsuya Tanaka on 20171217.
//  Copyright © 2017年 tattn. All rights reserved.
//

import Foundation

public extension String {
    public var localized: String {
        return NSLocalizedString(self, comment: self)
    }

    public func localized(withTableName tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: self)
    }
}

public extension String {
    public var url: URL? {
        return URL(string: self)
    }
}

public extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    subscript (bounds: PartialRangeUpTo<Int>) -> String {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[startIndex..<end])
    }

    subscript (bounds: PartialRangeThrough<Int>) -> String {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[startIndex...end])
    }

    subscript (bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        return String(self[start..<endIndex])
    }
}

public extension String {
    public var halfWidth: String {
        return transformFullWidthToHalfWidth(reverse: false)
    }

    public var fullWidth: String {
        return transformFullWidthToHalfWidth(reverse: true)
    }

    private func transformFullWidthToHalfWidth(reverse: Bool) -> String {
        let string = NSMutableString(string: self) as CFMutableString
        CFStringTransform(string, nil, kCFStringTransformFullwidthHalfwidth, reverse)
        return string as String
    }
}

public extension String {
    /// Compares 2 strings without case sensitivity
    ///
    /// - parameter otherString: The other string to compare
    ///
    /// - returns: true if they are the same. false otherwise
    func inSensitiveCompare(otherString : String) ->Bool {
        return self.caseInsensitiveCompare(otherString) == ComparisonResult.orderedSame
    }
    
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8),
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
    var toAttributed : NSAttributedString {
        return NSAttributedString(string: self)
    }
    func validate(withExpression expr : InputValidationExpression) -> Bool{
        let test = NSPredicate(format:"SELF MATCHES %@", expr.rawValue)
        return test.evaluate(with: self)
    }
}

extension Optional where Wrapped == String{
    
    /// This function will try to render the html in string with the specified font without losing the symbolic traits in the HTML.
    ///
    /// - Parameter fontToApply: The font to be applied on the html string.
    /// - Returns: Attributed string with the font specified. if no font specified, the attributed string with the defualt html font will be returned.
    func applyHtml(withFont fontToApply : UIFont?) -> NSMutableAttributedString?{
        
        //Convert to data
        guard let data = self?.data(using: .utf8, allowLossyConversion: true) else {
            return nil
        }
        
        //Create NSMutableAttriburedString form the data , if fails a nil will be returned
        guard let attr = try? NSMutableAttributedString(data: data,
                                                        options: [.documentType: NSAttributedString.DocumentType.html,
                                                                  .characterEncoding: String.Encoding.utf8.rawValue],
                                                        documentAttributes: nil
            ) else {
                return nil
        }
        
        //If there is no font to be applied the attributed string will be returned
        guard fontToApply != nil else{            
            return attr
        }
        
        //Ok, now in order to apply any font without losing the traits ,i will iterate through each range of the fontAttributedStringKey,
        //and copy the traits from the fetched font in the current range to apply it on the new created font using copySymbolicTraits function
        attr.enumerateAttribute(.font,
                                in: NSMakeRange(0,attr.length),
                                options: []) { (value, range, stop) in
                                    let originalFont = value as! UIFont
                                    if let newFont = Utilities.Font.copySymbolicTraits(from: originalFont, to: fontToApply!){
                                        attr.addAttribute(.font, value: newFont, range: range)
                                    }
        }
        return attr
    }  
}
