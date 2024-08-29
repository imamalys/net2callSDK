//
//  TextStyle.swift
//  Net2Call
//
//  Created by Imam on 23/07/24.
//

import UIKit

struct TextStyle {
    var fgColor:LightDarkColor
    var bgColor:LightDarkColor
    var allCaps:Bool
    var align:NSTextAlignment
    var font:String
    var size:Float
    
    func boldEd() -> TextStyle {
        return self.font.contains("Bold") ? self : TextStyle(fgColor: self.fgColor,bgColor: self.bgColor,allCaps: self.allCaps,align: self.align,font: self.font.replacingOccurrences(of: "Regular", with: "Bold"), size: self.size)
    }
}

extension UILabel {
    func applyStyleColors(_ style:TextStyle) {
        textColor = style.fgColor.get()
        backgroundColor = style.bgColor.get()
    }
    
    func applyStyle(_ style:TextStyle) {
        applyStyleColors(style)
        if (style.allCaps) {
            text = self.text?.uppercased()
            tag = 1
        }
        textAlignment = style.align
        let fontSizeMultiplier: Float = (UIDevice.ipad() ? 1.25 : UIDevice.is5SorSEGen1() ? 0.9 : 1.0)
        font = UIFont.init(name: style.font, size: CGFloat(style.size*fontSizeMultiplier))
    }
    
    func addIndicatorIcon(iconName:String,  padding:CGFloat = 5.0, y:CGFloat = 4.0, trailing: Bool = true) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named:iconName)?.tinted(with: VoipTheme.voipDrawableColor.get())
        imageAttachment.bounds = CGRect(x: 0.0, y: y , width: font.lineHeight - 2*padding, height: font.lineHeight - 2*padding)
        let iconString = NSMutableAttributedString(attachment: imageAttachment)
        let textXtring = NSMutableAttributedString(string: text != nil ? (!trailing ? " " : "") + text! + (trailing ? " " : "") : "")
        if (trailing) {
            textXtring.append(iconString)
            self.text = nil
            self.attributedText = textXtring
        } else {
            iconString.append(textXtring)
            self.text = nil
            self.attributedText = iconString
        }
    }
}
