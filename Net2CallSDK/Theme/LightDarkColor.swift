//
//  LightDarkColor.swift
//  Net2Call
//
//  Created by Imam on 23/07/24.
//

import Foundation
import UIKit

@objc class LightDarkColor : NSObject {
    var light: UIColor
    var dark : UIColor
    init(_ l:UIColor,_ d:UIColor){
        light = l
        dark = d
    }
    
    @objc func get() -> UIColor {
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .light {
                return light
            } else {
                return dark
            }
        } else {
            return light
        }
    }
    
}
