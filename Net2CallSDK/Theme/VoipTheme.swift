//
//  VoipTheme.swift
//  Net2Call
//
//  Created by Imam on 24/07/24.
//

import Foundation
import UIKit

@objc class VoipTheme : NSObject { // Names & values replicated from Android
    // Voip Colors
    @objc static let voip_dark_gray = UIColor(hex:"#4B5964")
    // Text styles
    static let fontName = "Roboto"
    // Light / Dark variations
    static let voipDrawableColor = LightDarkColor(voip_dark_gray,.white)
    static let call_display_name_duration = TextStyle(fgColor: LightDarkColor(.white,.white), bgColor: LightDarkColor(.clear,.clear), allCaps: false, align: .left, font: fontName+"-Regular", size: 17.0)
}
