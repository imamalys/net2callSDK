//
//  SingleHolder.swift
//  Net2CallSDK
//
//  Created by Imam on 16/07/24.
//

import Foundation

public class SingletonHolder<T, A> {
    private let creator: (A) -> T
    private var instance: T?
    private let lock = NSLock()

    public init(creator: @escaping (A) -> T) {
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

    public func create(arg: A) -> T {
        if let instance = instance {
            return instance
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        if let instance = instance {
            return instance
        } else {
            let createdInstance = creator(arg)
            instance = createdInstance
            return createdInstance
        }
    }

    public func required(arg: A) -> T {
        return get() ?? create(arg: arg)
    }
}
