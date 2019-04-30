//
//  Observable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// A type-erased `ObservableType`. 
///
/// 它表示一个push样式序列.
public class Observable<Element> : ObservableType {
    init() {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
    }

    // Observable 中并未直接实现 subscribe 方法，这里直接强制抛出错误，需要被重写。
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        rxAbstractMethod()
    }
    
    public func asObservable() -> Observable<Element> {
        return self
    }
    
    deinit {
#if TRACE_RESOURCES
        _ = Resources.decrementTotal()
#endif
    }

    // this is kind of ugly I know :(
    // Swift compiler reports "Not supported yet" when trying to override protocol extensions, so ¯\_(ツ)_/¯

    /// map 操作符的优化
    internal func composeMap<Result>(_ transform: @escaping (Element) throws -> Result) -> Observable<Result> {
        return _map(source: self, transform: transform)
    }
}

