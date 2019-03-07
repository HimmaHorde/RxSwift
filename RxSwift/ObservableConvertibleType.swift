//
//  ObservableConvertibleType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// protocol:可以转换为 Observable 序列的类型 (`Observable<E>`).
///
///    协议方法只有一个 asObservable ,
///    将自身转换为 Observable<E> 对象。
///
public protocol ObservableConvertibleType {
    /// 序列中元素的类型。
    associatedtype E

    /// 转为为 `Observable` 序列.
    ///
    /// - returns: 由 `self` 转化为的 Observable 序列
    func asObservable() -> Observable<E>
}
