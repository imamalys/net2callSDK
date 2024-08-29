//
//  CallState.swift
//  Net2Call
//
//  Created by Imam on 28/07/24.
//

import Foundation

///``State`` enum represents the different states a call can reach into.
public enum CallState:Int
{
    /// Initial state.
    case Idle = 0
    /// Incoming call received.
    case IncomingReceived = 1
    /// PushIncoming call received.
    case PushIncomingReceived = 2
    /// Outgoing call initialized.
    case OutgoingInit = 3
    /// Outgoing call in progress.
    case OutgoingProgress = 4
    /// Outgoing call ringing.
    case OutgoingRinging = 5
    /// Outgoing call early media.
    case OutgoingEarlyMedia = 6
    /// Connected.
    case Connected = 7
    /// Streams running.
    case StreamsRunning = 8
    /// Pausing.
    case Pausing = 9
    /// Paused.
    case Paused = 10
    /// Resuming.
    case Resuming = 11
    /// Referred.
    case Referred = 12
    /// Error.
    case Error = 13
    /// Call end.
    case End = 14
    /// Paused by remote.
    case PausedByRemote = 15
    /// The call's parameters are updated for example when video is asked by remote.
    case UpdatedByRemote = 16
    /// We are proposing early media to an incoming call.
    case IncomingEarlyMedia = 17
    /// We have initiated a call update.
    case Updating = 18
    /// The call object is now released.
    case Released = 19
    /// The call is updated by remote while not yet answered (SIP UPDATE in early
    /// dialog received)
    case EarlyUpdatedByRemote = 20
    /// We are updating the call while not yet answered (SIP UPDATE in early dialog
    /// sent)
    case EarlyUpdating = 21
}
