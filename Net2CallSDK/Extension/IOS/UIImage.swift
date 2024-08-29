//
//  UIImageExtensions.swift
//  Net2Call
//
//  Created by Imam on 24/07/24.
//

import Foundation
import UIKit

extension UIImage {
    func tinted(with color: UIColor?) -> UIImage? {
        if (color == nil) {
            return self
        }
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color!.set()
        self.withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: self.size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func withInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
    
    func withPadding(padding: CGFloat) -> UIImage? {
        let insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        return withInsets(insets: insets)
    }
}
