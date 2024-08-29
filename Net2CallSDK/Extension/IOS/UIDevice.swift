//
//  UIDeviceExtension.swift
//  Net2Call
//
//  Created by Imam on 23/07/24.
//


import Foundation
import UIKit
import AVFoundation

extension UIDevice {
    static func ipad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    static func is5SorSEGen1() -> Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
    
    static func hasNotch() -> Bool {
        if (UserDefaults.standard.bool(forKey: "hasNotch")) {
            return true
        }
        guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        UserDefaults.standard.setValue(true, forKey: "hasNotch")
        return true
    }
    
    static func notchHeight() -> CGFloat {
        guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, let sidePadding =  UIApplication.shared.keyWindow?.safeAreaInsets.left else {
            return 0
        }
        return [.landscapeRight,.landscapeLeft].contains(UIDevice.current.orientation) ? sidePadding : topPadding
    }
    
    static func switchedDisplayMode() -> Bool {
        let displayMode = UserDefaults.standard.string(forKey: "displayMode")
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .light {
                UserDefaults.standard.set("light", forKey: "displayMode")
            } else {
                UserDefaults.standard.set("dark", forKey: "displayMode")
            }
        }
        return displayMode != nil && displayMode != UserDefaults.standard.string(forKey: "displayMode")
    }
    
}

@objc class UIDeviceBridge : NSObject {
    static let displayModeSwitched = MutableLiveData<Bool>()
    @objc static func switchedDisplayMode() -> Bool {
        return UIDevice.switchedDisplayMode()
    }
    @objc static func notifyDisplayModeSwitch() {
        displayModeSwitched.notifyValue()
    }
}
