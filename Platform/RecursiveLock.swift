//
//  RecursiveLock.swift
//  Platform
//
//  Created by Krunoslav Zaher on 12/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if TRACE_RESOURCES
    /// 它可以允许同一线程多次加锁，而不会造成死锁。
    class RecursiveLock: NSRecursiveLock {
        override init() {
            _ = Resources.incrementTotal()
            super.init()
        }

        override func lock() {
            super.lock()
            _ = Resources.incrementTotal()
        }

        override func unlock() {
            super.unlock()
            _ = Resources.decrementTotal()
        }

        deinit {
            _ = Resources.decrementTotal()
        }
    }
#else
    /// 它可以允许同一线程多次加锁，而不会造成死锁。
    typealias RecursiveLock = NSRecursiveLock
#endif
