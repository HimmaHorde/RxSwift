//
//  Bag.swift
//  Platform
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Swift

let arrayDictionaryMaxSize = 30

struct BagKey {
    /**
    Unique identifier for object added to `Bag`.
     
    It's underlying type is UInt64. If we assume there in an idealized CPU that works at 4GHz,
     it would take ~150 years of continuous running time for it to overflow.
    */
    fileprivate let rawValue: UInt64
}

/**
存储对个 T 类型值的结构体

 单个元素可以存储多次。

 插入和删除的时间和空间复杂度为O(n)。

 它适用于存储少量的元素。
*/
struct Bag<T> : CustomDebugStringConvertible {
    /// 插入元素的标识符的类型。
    typealias KeyType = BagKey

    // key-value 键值对
    typealias Entry = (key: BagKey, value: T)

    // 自增key值
    private var _nextKey: BagKey = BagKey(rawValue: 0)

    // data

    // 存入的第一个变量
    var _key0: BagKey?
    var _value0: T?

    // then fill "array dictionary"
    var _pairs = ContiguousArray<Entry>()

    // last is sparse dictionary
    var _dictionary: [BagKey: T]?

    // 只有一个元素或者没有元素
    var _onlyFastPath = true

    /// Creates new empty `Bag`.
    init() {
    }
    
    /**
    插入元素
    
    - parameter element: 元素
    - returns: 返回 Key，key可以用来从 bag 中删除对应的值
    */
    mutating func insert(_ element: T) -> BagKey {
        let key = _nextKey

        _nextKey = BagKey(rawValue: _nextKey.rawValue &+ 1)

        if _key0 == nil {
            _key0 = key
            _value0 = element
            return key
        }

        _onlyFastPath = false

        // 大于最大值之后保存在字典中
        if _dictionary != nil {
            _dictionary![key] = element
            return key
        }

        // 低于最大值保存在数组中
        if _pairs.count < arrayDictionaryMaxSize {
            _pairs.append((key: key, value: element))
            return key
        }

        // 第一次赋值触发，初始化 _dictionary
        _dictionary = [key: element]
        
        return key
    }
    
    /// - returns: Number of elements in bag.
    var count: Int {
        let dictionaryCount: Int = _dictionary?.count ?? 0
        return (_value0 != nil ? 1 : 0) + _pairs.count + dictionaryCount
    }
    
    /// Removes all elements from bag and clears capacity.
    mutating func removeAll() {
        _key0 = nil
        _value0 = nil

        _pairs.removeAll(keepingCapacity: false)
        _dictionary?.removeAll(keepingCapacity: false)
    }
    
    /**
    移除指定 key 相关的值
    
    - parameter key: Key that identifies element to remove from bag.
    - returns: Element that bag contained, or nil in case element was already removed.
    */
    mutating func removeKey(_ key: BagKey) -> T? {
        if _key0 == key {
            _key0 = nil
            let value = _value0!
            _value0 = nil
            return value
        }

        if let existingObject = _dictionary?.removeValue(forKey: key) {
            return existingObject
        }

        for i in 0 ..< _pairs.count where _pairs[i].key == key {
            let value = _pairs[i].value
            _pairs.remove(at: i)
            return value
        }

        return nil
    }
}

extension Bag {
    /// A textual representation of `self`, suitable for debugging.
    var debugDescription : String {
        "\(self.count) elements in Bag"
    }
}

extension Bag {
    /// Enumerates elements inside the bag.
    ///
    /// - parameter action: Enumeration closure.
    func forEach(_ action: (T) -> Void) {
        if _onlyFastPath {
            if let value0 = _value0 {
                action(value0)
            }
            return
        }

        let value0 = _value0
        let dictionary = _dictionary

        if let value0 = value0 {
            action(value0)
        }

        for i in 0 ..< _pairs.count {
            action(_pairs[i].value)
        }

        if dictionary?.count ?? 0 > 0 {
            for element in dictionary!.values {
                action(element)
            }
        }
    }
}

extension BagKey: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

func ==(lhs: BagKey, rhs: BagKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
