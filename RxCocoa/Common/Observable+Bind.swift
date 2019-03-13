//
//  Observable+Bind.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 8/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


import RxSwift

extension ObservableType {
    
    /**
    创建新的订阅并向观察者发送元素。
    
    这种情况等同于 `subscribe` 方法, 但是表达的意思更加清晰，绑定 API 更加统一。
    
    - parameter to: 接收事件的观察者。
    - returns: 可用于取消订阅观察者的一次性对象.
    */
    public func bind<O: ObserverType>(to observer: O) -> Disposable where O.E == E {
        return self.subscribe(observer)
    }

    /**
     创建新的订阅并向观察者发送元素。

     这种情况等同于 `subscribe` 方法, 但是表达的意思更加清晰，绑定 API 更加统一。

     - parameter to: 接收事件的观察者。
     - returns: 可用于取消订阅观察者的一次性对象.
     */
    public func bind<O: ObserverType>(to observer: O) -> Disposable where O.E == E? {
        // 这地方进行了类型推断？ 是 MAP.R = O.E
        return self.map { $0 }.subscribe(observer)
    }

    /**
     Creates new subscription and sends elements to publish relay.
     
     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.
     
     - parameter to: Target publish relay for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    public func bind(to relay: PublishRelay<E>) -> Disposable {
        return self.subscribe { e in
            switch e {
            case let .next(element):
                relay.accept(element)
            case let .error(error):
                rxFatalErrorInDebug("Binding error to publish relay: \(error)")
            case .completed:
                break
            }
        }
    }
    
    /**
     Creates new subscription and sends elements to publish relay.
     
     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.
     
     - parameter to: Target publish relay for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    public func bind(to relay: PublishRelay<E?>) -> Disposable {
        return self.map { $0 as E? }.bind(to: relay)
    }
    
    /**
     Creates new subscription and sends elements to behavior relay.
     
     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.
     
     - parameter to: Target behavior relay for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    public func bind(to relay: BehaviorRelay<E>) -> Disposable {
        return self.subscribe { e in
            switch e {
            case let .next(element):
                relay.accept(element)
            case let .error(error):
                rxFatalErrorInDebug("Binding error to behavior relay: \(error)")
            case .completed:
                break
            }
        }
    }
    
    /**
     Creates new subscription and sends elements to behavior relay.
     
     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.
     
     - parameter to: Target behavior relay for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    public func bind(to relay: BehaviorRelay<E?>) -> Disposable {
        return self.map { $0 as E? }.bind(to: relay)
    }
    
    /**
    Subscribes to observable sequence using custom binder function.
    
    - parameter to: Function used to bind elements from `self`.
    - returns: Object representing subscription.
    */
    public func bind<R>(to binder: (Self) -> R) -> R {
        return binder(self)
    }

    /**
    Subscribes to observable sequence using custom binder function and final parameter passed to binder function
    after `self` is passed.
    
        public func bind<R1, R2>(to binder: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
            return binder(self)(curriedArgument)
        }
    
    - parameter to: Function used to bind elements from `self`.
    - parameter curriedArgument: Final argument passed to `binder` to finish binding process.
    - returns: Object representing subscription.
    */
    public func bind<R1, R2>(to binder: (Self) -> (R1) -> R2, curriedArgument: R1) -> R2 {
         return binder(self)(curriedArgument)
    }
    
    
    /**
    Subscribes an element handler to an observable sequence. 

    In case error occurs in debug mode, `fatalError` will be raised.
    In case error occurs in release mode, `error` will be logged.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
    public func bind(onNext: @escaping (E) -> Void) -> Disposable {
        return self.subscribe(onNext: onNext, onError: { error in
            rxFatalErrorInDebug("Binding error: \(error)")
        })
    }
}
