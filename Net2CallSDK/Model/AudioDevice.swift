//
//  AudioDevicw.swift
//  Net2Call
//
//  Created by Imam on 04/08/24.
//

import Foundation

public class AudioDeviceCore {
    private var type: AudioDeviceType
    private var deviceName: String
    private var isActive: Bool = false


    init(type: AudioDeviceType, deviceName: String) {
        self.type = type
        self.deviceName = deviceName
    }
}
