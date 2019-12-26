//
//  SubjectType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 表示既是 Observable 序列又是观察者对象
public protocol SubjectType : ObservableType {
    /// 观察者的类型
    ///
    /// 通常这种类型是自身的类型，但它不一定是。
    associatedtype Observer: ObserverType

    @available(*, deprecated, renamed: "Observer")
    typealias SubjectObserverType = Observer

    /// 自身生成观察者对象
    ///
    /// - returns: 观察者对象
    func asObserver() -> Observer

}
