//
//  AudioRouteUtil.swift
//  Net2Call
//
//  Created by Imam on 02/08/24.
//

import Foundation
import AVFoundation

@objc class AudioRouteUtils : NSObject {
    
    static var sdkManager : SDKManager? {
        get {
            SDKManager.holder.get()
        }
    }

    static private func applyAudioRouteChange( call: Call?, types: [AudioDevice.Kind], output: Bool = true) {
        let typesNames = types.map { String(describing: $0) }.joined(separator: "/")
        
        let currentCall = call != nil 
        ? call
        : sdkManager?.sdkCore?.currentCall != nil
        ? sdkManager?.sdkCore?.currentCall
        : sdkManager?.sdkCore?.calls[0]
        if (currentCall == nil) {
            NSLog("%@", "[Audio Route Helper] No call found, setting audio route on sdkManager?.sdkCore?")
        }
        
        let capability = output ? AudioDevice.Capabilities.CapabilityPlay : AudioDevice.Capabilities.CapabilityRecord
        var found = false
        
        sdkManager?.sdkCore?.audioDevices.forEach { (audioDevice) in
            NSLog("%@", "[Audio Route Helper] registered coe audio devices are : [\(audioDevice.deviceName)] [\(audioDevice.type)] [\(audioDevice.capabilities)] ")
        }

        sdkManager?.sdkCore?.audioDevices.forEach { (audioDevice) in
            if (!found && types.contains(audioDevice.type) && audioDevice.hasCapability(capability: capability)) {
                if (currentCall != nil) {
                    NSLog("%@", "[Audio Route Helper] Found [\(audioDevice.type)] \(output ?  "playback" : "recorder") audio device [\(audioDevice.deviceName)], routing call audio to it")
                    if (output) {
                        currentCall?.outputAudioDevice = audioDevice
                    }
                    else {
                        currentCall?.inputAudioDevice = audioDevice
                    }
                } else {
                    NSLog("%@", "[Audio Route Helper] Found [\(audioDevice.type)] \(output ?  "playback" : "recorder") audio device [\(audioDevice.deviceName)], changing sdkManager?.sdkCore? default audio device")
                    if (output) {
                        sdkManager?.sdkCore?.outputAudioDevice = audioDevice
                    } else {
                        sdkManager?.sdkCore?.inputAudioDevice = audioDevice
                    }
                }
                found = true
            }
        }
        if (!found) {
            NSLog("%@", "[Audio Route Helper] Couldn't find \(typesNames) audio device")
        }
    }
    
    static private func changeCaptureDeviceToMatchAudioRoute(call: Call?, types: [AudioDevice.Kind]) {
        switch (types.first) {
        case .Bluetooth :if (isBluetoothAudioRecorderAvailable()) {
            NSLog("%@", "[Audio Route Helper] Bluetooth device is able to record audio, also change input audio device")
            applyAudioRouteChange(call: call, types: [AudioDevice.Kind.Bluetooth], output: false)
        }
        case .Headset, .Headphones : if (isHeadsetAudioRecorderAvailable()) {
            NSLog("%@", "[Audio Route Helper] Headphones/headset device is able to record audio, also change input audio device")
            applyAudioRouteChange(call:call,types: [AudioDevice.Kind.Headphones, AudioDevice.Kind.Headset], output:false)
        }
        default: applyAudioRouteChange(call:call,types: [AudioDevice.Kind.Microphone], output:false)
        }
    }
    
    static private func routeAudioTo( call: Call?, types: [AudioDevice.Kind]) {
        let currentCall = call != nil
        ? call
        : sdkManager?.sdkCore?.currentCall != nil
        ? sdkManager?.sdkCore?.currentCall
        :  sdkManager?.sdkCore?.calls[0]
        if (call != nil || currentCall != nil) {
            let callToUse = call != nil ? call : currentCall
            applyAudioRouteChange(call: callToUse, types: types)
            changeCaptureDeviceToMatchAudioRoute(call: callToUse, types: types)
        } else {
            applyAudioRouteChange(call: call, types: types)
            changeCaptureDeviceToMatchAudioRoute(call: call, types: types)
        }
    }
    
    static func routeAudioToEarpiece(call: Call? = nil) {
        routeAudioTo(call: call, types: [AudioDevice.Kind.Microphone]) // on iOS Earpiece = Microphone
    }
    
    static func routeAudioToSpeaker(call: Call? = nil) {
        routeAudioTo(call: call, types: [AudioDevice.Kind.Speaker])
    }
    
    @objc static func routeAudioToSpeaker() {
        routeAudioTo(call: nil, types: [AudioDevice.Kind.Speaker])
    }
    
    static func routeAudioToBluetooth(call: Call? = nil) {
        routeAudioTo(call: call, types: [AudioDevice.Kind.Bluetooth])
    }
    
    static func routeAudioToHeadset(call: Call? = nil) {
        routeAudioTo(call: call, types: [AudioDevice.Kind.Headphones, AudioDevice.Kind.Headset])
    }
    
    static func isSpeakerAudioRouteCurrentlyUsed(call: Call? = nil) -> Bool {
        
        let currentCall = call != nil
        ? call
        : sdkManager?.sdkCore?.currentCall != nil
        ? sdkManager?.sdkCore?.currentCall
        : sdkManager?.sdkCore?.calls[0]
        if (currentCall == nil) {
            NSLog("%@", "[Audio Route Helper] No call found, setting audio route on sdkManager?.sdkCore?")
        }
        
        let audioDevice = currentCall != nil ? currentCall!.outputAudioDevice : sdkManager?.sdkCore?.outputAudioDevice
        NSLog("%@", "[Audio Route Helper] Playback audio currently in use is [\(audioDevice?.deviceName ?? "n/a")] with type (\(audioDevice?.type ?? .Unknown)")
        return audioDevice?.type == AudioDevice.Kind.Speaker
    }
    
    static func isBluetoothAudioRouteCurrentlyUsed(call: Call? = nil) -> Bool {
        if (sdkManager?.sdkCore?.callsNb == 0) {
            NSLog("%@", "[Audio Route Helper] No call found, so bluetooth audio route isn't used")
            return false
        }
        let currentCall = call != nil  ? call : sdkManager?.sdkCore?.currentCall != nil ? sdkManager?.sdkCore?.currentCall : sdkManager?.sdkCore?.calls[0]
       
        let audioDevice =  currentCall?.outputAudioDevice
        NSLog("%@", "[Audio Route Helper] Playback audio device currently in use is [\(audioDevice?.deviceName ?? "n/a")] with type (\(audioDevice?.type  ?? .Unknown)")
        return audioDevice?.type == AudioDevice.Kind.Bluetooth
    }
    
    static func isBluetoothAudioRouteAvailable() -> Bool {
        if let device = sdkManager?.sdkCore?.audioDevices.first(where: { $0.type == AudioDevice.Kind.Bluetooth &&  $0.hasCapability(capability: .CapabilityPlay) }) {
            NSLog("[Audio Route Helper] Found bluetooth audio device [\(device.deviceName)]")
            return true
        }
        return false
    }
    
    static private func isBluetoothAudioRecorderAvailable() -> Bool {
        if let device = sdkManager?.sdkCore?.audioDevices.first(where: { $0.type == AudioDevice.Kind.Bluetooth &&  $0.hasCapability(capability: .CapabilityRecord) }) {
            NSLog("%@", "[Audio Route Helper] Found bluetooth audio recorder [\(device.deviceName)]")
            return true
        }
        return false
    }
    
    static func isHeadsetAudioRouteAvailable() -> Bool {
        if let device = sdkManager?.sdkCore?.audioDevices.first(where: { ($0.type == AudioDevice.Kind.Headset||$0.type == AudioDevice.Kind.Headphones) &&  $0.hasCapability(capability: .CapabilityPlay) }) {
            NSLog("%@", "[Audio Route Helper] Found headset/headphones audio device  [\(device.deviceName)]")
            return true
        }
        return false
    }
    
    static private func isHeadsetAudioRecorderAvailable() -> Bool {
        if let device = sdkManager?.sdkCore?.audioDevices.first(where: { ($0.type == AudioDevice.Kind.Headset||$0.type == AudioDevice.Kind.Headphones) &&  $0.hasCapability(capability: .CapabilityRecord) }) {
            NSLog("%@", "[Audio Route Helper] Found headset/headphones audio recorder  [\(device.deviceName)]")
            return true
        }
        return false
    }
    

    
    static func isReceiverEnabled() -> Bool {
        if let outputDevice = sdkManager?.sdkCore?.outputAudioDevice {
            return outputDevice.type == AudioDevice.Kind.Microphone
        }
        return false
    }
    
}
