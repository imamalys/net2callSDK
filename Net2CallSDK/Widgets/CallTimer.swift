//
//  CallTImer.swift
//  Net2Call
//
//  Created by Imam on 23/07/24.
//

import Foundation
import linphonesw


class CallTimer : StyledLabel  {
    
    let min_width = 50.0
    
    let formatter = DateComponentsFormatter()
    var startDate = Date()
    var call:Call? = nil {
        didSet {
            self.format()
        }
    }
    
    var conference:Conference? = nil {
        didSet {
            self.format()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init (_ text:String?, _ style:TextStyle, _ call:Call? = nil) {
        super.init(style,text)
        self.call = call
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            var elapsedTime: TimeInterval = 0
            if (self.call != nil || self.conference != nil) {
                elapsedTime = Date().timeIntervalSince(self.startDate)
            }
            self.formatter.string(from: elapsedTime).map {
                self.text = $0.hasPrefix("0:") ? "0" + $0 : $0
            }
        }
        minWidth(min_width).done()

    }

    
    func format() {
        guard let duration = self.call != nil ? self.call!.duration : self.conference != nil ? self.conference!.duration: nil else {
            return
        }
        startDate = Date().advanced(by: -TimeInterval(duration))
    }
}
