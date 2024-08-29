//
//  StyledLabel.swift
//  Net2Call
//
//  Created by Imam on 23/07/24.
//

import Foundation
import UIKit

class StyledLabel: UILabel {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init (_ style:TextStyle, _ text:String? = nil) {
        super.init(frame: .zero)
        self.text = text
        applyStyle(style)
        UIDeviceBridge.displayModeSwitched.observe { _ in
            self.applyStyleColors(style)
        }
   }
}
