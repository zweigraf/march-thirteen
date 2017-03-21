//
//  UIImageExtension.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 21.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit
import CoreGraphics

public extension UIImage {
    static func initialsImage(for string: String, size: CGSize = CGSize(width: 30, height: 30)) -> UIImage? {
        let initials = string.components(separatedBy: CharacterSet.whitespaces.union(.punctuationCharacters))
            .map {
                let startIndex = $0.startIndex
                let secondIndex = $0.index(after: startIndex)
                return $0.substring(to: secondIndex)
            }.joined().uppercased()
        
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(UIColor.darkGray.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 12)!,
                     NSParagraphStyleAttributeName: paragraphStyle,
                     NSForegroundColorAttributeName: UIColor.white]

        let attributedString = NSAttributedString(string: initials, attributes: attrs)
        let stringSize = attributedString.size()
        let xOffset = (size.width - stringSize.width) / 2
        let yOffset = (size.height - stringSize.height) / 2
        
        attributedString.draw(in: CGRect(x: xOffset, y: yOffset, width: stringSize.width, height: stringSize.height))
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
