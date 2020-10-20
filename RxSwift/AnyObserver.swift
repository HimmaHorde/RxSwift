//
//  AnyObserver.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// A type-erased `ObserverType`. [类型擦除](https://www.jianshu.com/p/0a9c5c66a5fd)
///
/// Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying observer type.
public struct AnyObserver<Element> : ObserverType {
    /// 匿名事件处理程序类型
    public typealias EventHandler = (Event<Element>) -> Void

    private let observer: EventHandler

    /// 构造一个实例, `on(event)` 方法调用 `eventHandler(event)`
    ///
    /// - parameter eventHandler: Event handler that observes sequences events.
    public init(eventHandler: @escaping EventHandler) {
        self.observer = eventHandler
    }
    
    /// 构造一个实例,`on(event)` 方法调用 `observer.on(event)`.
    ///
    /// 用于将匿名和私有的观察者转化为 AnyObserver
    ///
    /// - parameter observer: 接受序列时间的观察者
    public init<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        // 持有 observe 的 on 方法，形成强引用。
        self.observer = observer.on
    }
    
    /// 发送 `event` 给这个观察者.
    ///
    /// - parameter event: 事件实例.
    public func on(_ event: Event<Element>) {
        self.observer(event)
    }

    /// Erases type of observer and returns canonical observer.
    ///
    /// - returns: type erased observer.
    public func asObserver() -> AnyObserver<Element> {
        self
    }
}

extension AnyObserver {
    /// 观察者`AnyObserver`集合
    typealias s = Bag<(Event<Element>) -> Void>
}

extension ObserverType {
    /// 可擦除类型观察者转化为 AnyObserver 类型
    ///
    /// - returns: type erased observer.
    public func asObserver() -> AnyObserver<Element> {
        AnyObserver(self)
    }

    /// 使用自定义转换方法将R类型的观察者转换为E类型。每个发送到结果观察者的事件都被转换并发送到“self”。
    ///
    /// - returns: observer that transforms events.
    public func mapObserver<Result>(_ transform: @escaping (Result) throws -> Element) -> AnyObserver<Result> {
        AnyObserver { e in
            self.on(e.map(transform))
        }
    }
}
