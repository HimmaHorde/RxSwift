//
//  ObservableType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 协议:定义了 subscribe 方法,继承自 `ObservableConvertibleType`。
public protocol ObservableType: ObservableConvertibleType  {

    /**
    传入观察者，接收序列的消息
    
    ### Grammar
    
    **Next\* (Error | Completed)?**
    
    * sequences can produce zero or more elements so zero or more `Next` events can be sent to `observer`
    * once an `Error` or `Completed` event is sent, the sequence terminates and can't produce any other elements
    
    It is possible that events are sent from different threads, but no two events can be sent concurrently to
    `observer`.
    
    ### Resource Management
    
    When sequence sends `Complete` or `Error` event all internal resources that compute sequence elements
    will be freed.
    
    To cancel production of sequence elements and free resources immediately, call `dispose` on returned
    subscription.
    
    - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
    */
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element
}

extension ObservableType {
    /// 默认实现：将遵循 `ObservableType` 协议的对象转化为 `Observable` 对象.
    public func asObservable() -> Observable<Element> {
        // temporary workaround
        //return Observable.create(subscribe: self.subscribe)
        Observable.create { o in self.subscribe(o) }
    }
}
