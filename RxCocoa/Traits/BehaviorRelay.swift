//
//  BehaviorRelay.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 10/7/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// 包装`BehaviorSubject`。
///
/// 不会产生 error or completed 事件
public final class BehaviorRelay<Element>: ObservableType {
    public typealias E = Element

    private let _subject: BehaviorSubject<Element>

    /// 接受`event`并将其发送给观察者
    public func accept(_ event: Element) {
        self._subject.onNext(event)
    }

    /// behavior subject 的当前值
    public var value: Element {
        // this try! is ok because subject can't error out or be disposed
        return try! self._subject.value()
    }

    /// 使用初始值初始化
    public init(value: Element) {
        self._subject = BehaviorSubject(value: value)
    }

    /// 订阅的观察者
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return self._subject.subscribe(observer)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        return self._subject.asObservable()
    }
}
