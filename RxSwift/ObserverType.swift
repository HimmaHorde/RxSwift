//
//  ObserverType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Supports push-style iteration over an observable sequence.
public protocol ObserverType {
    /// 观察者可以订阅序列的元素类型
    associatedtype Element

    @available(*, deprecated, message: "Use `Element` instead.")
    typealias E = Element

    /// 将 `Observable` 序列事件通知观察者
    ///
    /// - parameter event: 发生的事件
    func on(_ event: Event<Element>)

}

/// 为 next, error, completed 事件提供便捷 API
extension ObserverType {
    
    /// Convenience method equivalent to `on(.next(element: Element))`
    ///
    /// - parameter element: Next element to send to observer(s)
    public func onNext(_ element: Element) {
        self.on(.next(element))
    }
    
    /// Convenience method equivalent to `on(.completed)`
    public func onCompleted() {
        self.on(.completed)
    }
    
    /// Convenience method equivalent to `on(.error(Swift.Error))`
    /// - parameter error: Swift.Error to send to observer(s)
    public func onError(_ error: Swift.Error) {
        self.on(.error(error))
    }
}
