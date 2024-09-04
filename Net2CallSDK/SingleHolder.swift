//
//  SingleHolder.swift
//  Net2CallSDK
//
//  Created by Imam on 16/07/24.
//

import Foundation

public class SingletonHolder<T> {
    private let creator: () -> T
    private var instance: T?
    private let lock = NSLock()

    public init(creator: @escaping () -> T) {
        self.creator = creator
    }

    public var exists: Bool {
        return instance != nil
    }

    public func destroy() {
        lock.lock()
        defer { lock.unlock() }
        instance = nil
    }

    public func get() -> T? {
        lock.lock()
        defer { lock.unlock() }
        return instance
    }

    public func create() -> T {
        if let instance = instance {
            return instance
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        if let instance = instance {
            return instance
        } else {
            let createdInstance = creator()
            instance = createdInstance
            return createdInstance
        }
    }

    public func required() -> T {
        return get() ?? create()
    }
}
