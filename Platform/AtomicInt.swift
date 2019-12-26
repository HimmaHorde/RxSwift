//
//  AtomicInt.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NSLock

final class AtomicInt: NSLock {
    fileprivate var value: Int32
    public init(_ value: Int32 = 0) {
        self.value = value
    }
}

/// 原子加法
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func add(_ this: AtomicInt, _ value: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value += value
    this.unlock()
    return oldValue
}

/// 原子减法
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func sub(_ this: AtomicInt, _ value: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value -= value
    this.unlock()
    return oldValue
}

/// 或运算
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func fetchOr(_ this: AtomicInt, _ mask: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value |= mask
    this.unlock()
    return oldValue
}

/// 从原子对象读取值
@inline(__always)
func load(_ this: AtomicInt) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.unlock()
    return oldValue
}

/// 自增 1
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func increment(_ this: AtomicInt) -> Int32 {
    add(this, 1)
}

/// 自减 1
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func decrement(_ this: AtomicInt) -> Int32 {
    sub(this, 1)
}

/// 与运算不为 0
/// ！0 true
@inline(__always)
func isFlagSet(_ this: AtomicInt, _ mask: Int32) -> Bool {
    (load(this) & mask) != 0
}
