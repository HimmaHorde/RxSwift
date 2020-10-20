//
//  PublishRelay.swift
//  RxRelay
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// 包装 `PublishSubject` 的结构体，不需要初始值。
///
/// 不会产生 error or completed 事件
public final class PublishRelay<Element>: ObservableType {
    private let subject: PublishSubject<Element>
    
    // Accepts `event` and emits it to subscribers
    public func accept(_ event: Element) {
        self.subject.onNext(event)
    }
    
    /// Initializes with internal empty subject.
    public init() {
        self.subject = PublishSubject()
    }

    /// Subscribes observer
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        self.subject.subscribe(observer)
    }
    
    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        self.subject.asObservable()
    }
}
