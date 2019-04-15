//
//  InvocableType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 11/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 协议：执行事件
protocol InvocableType {
    func invoke()
}

/// 使用给定值执行事件
protocol InvocableWithValueType {
    associatedtype Value

    func invoke(_ value: Value)
}
