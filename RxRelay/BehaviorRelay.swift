//
//  BehaviorRelay.swift
//  RxRelay
//
//  Created by Krunoslav Zaher on 10/7/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// 包装`BehaviorSubject`。
///
/// 不会产生 error or completed 事件
public final class BehaviorRelay<Element>: ObservableType {
    private let subject: BehaviorSubject<Element>

    /// 接受`event`并将其发送给观察者
    public func accept(_ event: Element) {
        self.subject.onNext(event)
    }

    /// behavior subject 的当前值
    public var value: Element {
        // this try! is ok because subject can't error out or be disposed
        return try! self.subject.value()
    }

    /// 使用初始值初始化
    public init(value: Element) {
        self.subject = BehaviorSubject(value: value)
    }

    /// 订阅的观察者
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        self.subject.subscribe(observer)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        self.subject.asObservable()
    }
}
