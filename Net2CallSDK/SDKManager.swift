//
//  SDKManager.swift
//  net2call-sdk
//
//  Created by Imam on 12/07/24.
//

import Foundation
import UIKit

public protocol SDKDelegate {
    func onCallStateChanged(state: CallState)
    func onConnectSuccess()
}

public class SDKManager {
    var sdkCore: Core?
    var mRegistrationDelegate : CoreDelegate!
    @Published public var loggedIn: Bool = false
    let formatter = DateComponentsFormatter()
    var startDate = Date()
    var durationCall: Call? = nil {
        didSet {
            self.format()
        }
    }
    
    public var delegate: SDKDelegate?

    public static let holder = SingletonHolder<SDKManager, String> {_ in
        return SDKManager()
    }
    
    public init() {
        LoggingService.Instance.logLevel = LogLevel.Debug
        
        do {
            let factory = Factory.Instance
            sdkCore = try! factory.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
            sdkCore?.videoCaptureEnabled = false
            sdkCore?.videoDisplayEnabled = false
            sdkCore?.ipv6Enabled = false
            sdkCore?.videoActivationPolicy!.automaticallyAccept = false
            try sdkCore?.start()
        } catch {
            print("Failed to initialize Linphone core: \(error)")
        }
        
        mRegistrationDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
            // This function will be called each time a call state changes,
            // which includes new incoming/outgoing calls
            if (state == .IncomingReceived) {
                self.delegate?.onCallStateChanged(state: .IncomingReceived)
            }
            else if (state == .OutgoingInit) {
                // First state an outgoing call will go through
                self.sdkCore?.activateAudioSession(actived: true)
            } else if (state == .OutgoingProgress) {
                // Right after outgoing init
                self.sdkCore?.activateAudioSession(actived: true)
                self.delegate?.onCallStateChanged(state: .OutgoingProgress)
            } else if (state == .OutgoingRinging) {
                // This state will be reached upon reception of the 180 RINGING
            } else if (state == .Connected) {
                // When the 200 OK has been received
                self.sdkCore?.activateAudioSession(actived: true)
                self.delegate?.onCallStateChanged(state: .Connected)
            } else if (state == .StreamsRunning) {
                // This state indicates the call is active.
                // You may reach this state multiple times, for example after a pause/resume
                // or after the ICE negotiation completes
                // Wait for the call to be connected before allowing a call update
                self.sdkCore?.activateAudioSession(actived: true)
                self.delegate?.onCallStateChanged(state: .Connected)
            } else if (state == .Pausing) {
                // When you put a call in pause, it will became Paused
                self.delegate?.onCallStateChanged(state: .Paused)
            } else if (state == .Paused) {
                // When you put a call in pause, it will became Paused
                self.delegate?.onCallStateChanged(state: .Paused)
            } else if (state == .PausedByRemote) {
                // When the remote end of the call pauses it, it will be PausedByRemote
                self.delegate?.onCallStateChanged(state: .Paused)
            } else if (state == .Updating) {
                // When we request a call update, for example when toggling video
            } else if (state == .UpdatedByRemote) {
                // When the remote requests a call update
            } else if (state == .End) {
                // Call state will be released shortly after the End state
                self.sdkCore?.activateAudioSession(actived: false)
                self.delegate?.onCallStateChanged(state: .Released)
            } else if (state == .Released) {
                // Call state will be released shortly after the End state
                self.sdkCore?.activateAudioSession(actived: false)
                self.delegate?.onCallStateChanged(state: .Released)
            } else if (state == .Error) {
                
            }
        }, onAudioDeviceChanged: {(core: Core, audio: AudioDevice) in
            
        }, onAudioDevicesListUpdated: {(core: Core) in
            
        }, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
            
            // If account has been configured correctly, we will go through Progress and Ok states
            // Otherwise, we will be Failed.
            NSLog("New registration state is \(state) for user id \( String(describing: account.params?.identityAddress?.asString()))\n")
            if (state == .Ok) {
                self.loggedIn = true
                self.delegate?.onConnectSuccess()
//                self.sdkCore?.configureAudioSession()
            } else if (state == .Cleared) {
                self.loggedIn = false
            }
            
        })
        
        sdkCore?.addDelegate(delegate: mRegistrationDelegate)
    }
    
    public func login(username: String, passwd: String, domain: String, transportType: String, port: String?) {
        do {
            delete()
            // Get the transport protocol to use.
            // TLS is strongly recommended
            // Only use UDP if you don't have the choice
            var transport : TransportType
            if (transportType == "TLS") { transport = TransportType.Tls }
            else if (transportType == "TCP") { transport = TransportType.Tcp }
            else  { transport = TransportType.Udp }
            
            // To configure a SIP account, we need an Account object and an AuthInfo object
            // The first one is how to connect to the proxy server, the second one stores the credentials
            
            // The auth info can be created from the Factory as it's only a data class
            // userID is set to null as it's the same as the username in our case
            // ha1 is set to null as we are using the clear text password. Upon first register, the hash will be computed automatically.
            // The realm will be determined automatically from the first register, as well as the algorithm
            let authInfo = try Factory.Instance.createAuthInfo(username: username, userid: "", passwd: passwd, ha1: "", realm: "", domain: domain)
            
            // Account object replaces deprecated ProxyConfig object
            // Account object is configured through an AccountParams object that we can obtain from the Core
            let accountParams = try sdkCore?.createAccountParams()
            
            // A SIP account is identified by an identity address that we can construct from the username and domain
            let identity = try Factory.Instance.createAddress(addr: String("sip:" + username + "@" + domain))
            
            // We also need to configure where the proxy server is located
            let address = try Factory.Instance.createAddress(addr: String("sip:" + domain))
            
            try! accountParams?.setIdentityaddress(newValue: identity)
            
            // We use the Address object to easily set the transport protocol
            try address.setTransport(newValue: transport)
            
            if let portNumber = port {
                try address.setPort(newValue: Int(portNumber)!)
            }
            
            try accountParams?.setServeraddress(newValue: address)
            // And we ensure the account will start the registration process
            accountParams?.registerEnabled = true
            
            // Now that our AccountParams is configured, we can create the Account object
            let account = try sdkCore?.createAccount(params: accountParams!)
            
            // Now let's add our objects to the Core
            sdkCore?.addAuthInfo(info: authInfo)
            try sdkCore?.addAccount(account: account!)
            
            // Also set the newly added account as default
            sdkCore?.defaultAccount = account
            
        } catch { NSLog(error.localizedDescription) }
    }
        
    public func unregister() {
        // Here we will disable the registration of our Account
        if let account = sdkCore?.defaultAccount {
            
            let params = account.params
            // Returned params object is const, so to make changes we first need to clone it
            let clonedParams = params?.clone()
            
            // Now let's make our changes
            clonedParams?.registerEnabled = false
            
            // And apply them
            account.params = clonedParams
        }
    }
    
    public func delete() {
        // To completely remove an Account
        if let account = sdkCore?.defaultAccount {
            sdkCore?.removeAccount(account: account)
            
            // To remove all accounts use
            sdkCore?.clearAccounts()
            
            // Same for auth info
            sdkCore?.clearAllAuthInfo()
        }
    }
    
    public func outgoingCall(address: String) {
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            let remoteAddress = try Factory.Instance.createAddress(addr: address)
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try sdkCore?.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params?.mediaEncryption = MediaEncryption.None
            params?.lowBandwidthEnabled = true
            // If we wanted to start the call with video directly
            //params.videoEnabled = true
            
            // Finally we start the call
            sdkCore?.configureAudioSession()
            let _ = sdkCore?.inviteAddressWithParams(addr: remoteAddress, params: params!)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch { NSLog(error.localizedDescription) }
    }
    
    public func acceptCall() {
            // IMPORTANT : Make sure you allowed the use of the microphone (see key "Privacy - Microphone usage description" in Info.plist) !
            do {
                // if we wanted, we could create a CallParams object
                // and answer using this object to make changes to the call configuration
                // (see OutgoingCall tutorial)
                try sdkCore?.currentCall?.accept()
            } catch { NSLog(error.localizedDescription) }
        }

        
    public func terminateCall() {
        do {
            if (sdkCore?.callsNb == 0) { return }
            
            // If the call state isn't paused, we can get it using core.currentCall
            let coreCall = (sdkCore?.currentCall != nil) ? sdkCore?.currentCall : sdkCore?.calls[0]
            
            // Terminating a call is quite simple
            if let call = coreCall {
                try call.terminate()
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
    public func currentCall() -> Call? {
        return sdkCore?.currentCall
    }
    
    public func pauseOrResume() {
        do {
            if (sdkCore?.callsNb == 0) { return }
            let coreCall = (sdkCore?.currentCall != nil) ? sdkCore?.currentCall : sdkCore?.calls[0]
            
            if let call = coreCall {
                if (call.state != Call.State.Paused && call.state != Call.State.Pausing) {
                    // If our call isn't paused, let's pause it
                    try call.pause()
                } else if (call.state != Call.State.Resuming) {
                    // Otherwise let's resume it
                    try call.resume()
                }
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
    public func setAudioDevices(deviceType: AudioDeviceType) {
        switch deviceType {
        case .Microphone:
            AudioRouteUtils.routeAudioToSpeaker(call: nil)
        default:
            AudioRouteUtils.routeAudioToEarpiece(call: nil)
        }
    }
    
    public func setMicEnabled(isEnabled: Bool) {
        sdkCore?.micEnabled = isEnabled
    }
    
    public func sendDTMF(input: String) {
        do {
            if (sdkCore?.callsNb == 0) { return }
            let coreCall = (sdkCore?.currentCall != nil) ? sdkCore?.currentCall : sdkCore?.calls[0]
            
            if let call = coreCall {
                try call.sendDtmfs(dtmfs: input)
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
    public func setDuration(durationView: UILabel) {
        durationCall = SDKManager.holder.get()?.currentCall()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            var elapsedTime: TimeInterval = 0
            if (self.durationCall != nil) {
                elapsedTime = Date().timeIntervalSince(self.startDate)
            }
            self.formatter.string(from: elapsedTime).map {
                durationView.text = $0.hasPrefix("0:") ? "0" + $0 : $0
            }
        }
    }
    
    func format() {
        guard let duration = durationCall?.duration else {
            return
        }
        startDate = Date().advanced(by: -TimeInterval(duration))
    }
}
