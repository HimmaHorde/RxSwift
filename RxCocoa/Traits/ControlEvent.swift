//
//  ControlEvent.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 8/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// 拓展 `ControlEvent` 的协议.
public protocol ControlEventType : ObservableType {

    /// - returns: `ControlEvent` interface
    func asControlEvent() -> ControlEvent<Element>
}

/**
    ControlEvent 是专门用于描述 UI 所产生的事件特征可观察序列。

    Properties:

    - 它不会在订阅时发送任何初始值,
    - 当控件释放时，序列就完成了,
    - 当控件释放时，结束序列,
    - 不会产生 error 事件
    - 在主线程 `MainScheduler.instance` 发送事件。


    **The implementation of `ControlEvent` will ensure that sequence of events is being subscribed on main scheduler
     (`subscribe(on: ConcurrentMainScheduler.instance)` behavior).**

    **It is the implementor’s responsibility to make sure that all other properties enumerated above are satisfied.**

    **If they aren’t, using this trait will communicate wrong properties, and could potentially break someone’s code.**

    **If the `events` observable sequence passed into the initializer doesn’t satisfy all enumerated
     properties, don’t use this trait.**
*/
public struct ControlEvent<PropertyType> : ControlEventType {
    public typealias Element = PropertyType

    let events: Observable<PropertyType>

    /// Initializes control event with a observable sequence that represents events.
    ///
    /// - parameter events: Observable sequence that represents events.
    /// - returns: Control event created with a observable sequence of events.
    public init<Ev: ObservableType>(events: Ev) where Ev.Element == Element {
        self.events = events.subscribe(on: ConcurrentMainScheduler.instance)
    }

    /// Subscribes an observer to control events.
    ///
    /// - parameter observer: Observer to subscribe to events.
    /// - returns: Disposable object that can be used to unsubscribe the observer from receiving control events.
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        self.events.subscribe(observer)
    }

    /// - returns: `Observable` interface.
    public func asObservable() -> Observable<Element> {
        self.events
    }

    /// - returns: `ControlEvent` interface.
    public func asControlEvent() -> ControlEvent<Element> {
        self
    }
}
