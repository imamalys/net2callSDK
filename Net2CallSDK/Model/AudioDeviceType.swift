//
//  AudioDeviceType.swift
//  Net2Call
//
//  Created by Imam on 04/08/24.
//

import Foundation

public enum AudioDeviceType: Int {
    /// Unknown.
    case Unknown = 0
    /// Microphone.
    case Microphone = 1
    /// Earpiece.
    case Earpiece = 2
    /// Speaker.
    case Speaker = 3
    /// Bluetooth.
    case Bluetooth = 4
    /// Bluetooth A2DP.
    case BluetoothA2DP = 5
    /// Telephony.
    case Telephony = 6
    /// AuxLine.
    case AuxLine = 7
    /// GenericUsb.
    case GenericUsb = 8
    /// Headset.
    case Headset = 9
    /// Headphones.
    case Headphones = 10
    /// Hearing Aid.
    case HearingAid = 11
}
