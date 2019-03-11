//
//  AtomicInt.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxAtomic

typealias AtomicInt = RxAtomic.AtomicInt

extension AtomicInt {
    public init(_ value: Int32) {
        self.init()
        AtomicInt_initialize(&self, value)
    }
}

/// 原子加法
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func add(_ this: UnsafeMutablePointer<AtomicInt>, _ value: Int32) -> Int32 {
    return AtomicInt_add(this, value)
}

/// 原子减法
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func sub(_ this: UnsafeMutablePointer<AtomicInt>, _ value: Int32) -> Int32 {
    return AtomicInt_sub(this, value)
}

/// 或运算
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func fetchOr(_ this: UnsafeMutablePointer<AtomicInt>, _ mask: Int32) -> Int32 {
    return AtomicInt_fetchOr(this, mask)
}

/// 从原子对象读取值
@inline(__always)
func load(_ this: UnsafeMutablePointer<AtomicInt>) -> Int32 {
    return AtomicInt_load(this)
}

/// 自增 1
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func increment(_ this: UnsafeMutablePointer<AtomicInt>) -> Int32 {
    return add(this, 1)
}

/// 自减 1
/// 返回值为原子对象先前保有的值
@discardableResult
@inline(__always)
func decrement(_ this: UnsafeMutablePointer<AtomicInt>) -> Int32 {
    return sub(this, 1)
}

/// 与运算不为 0
/// ！0 true
@inline(__always)
func isFlagSet(_ this: UnsafeMutablePointer<AtomicInt>, _ mask: Int32) -> Bool {
    return (load(this) & mask) != 0
}
