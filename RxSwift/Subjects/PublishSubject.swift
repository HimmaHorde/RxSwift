//
//  PublishSubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 表示同时是可观察序列和观察者的对象。它不需要初始值就能创建。
///
/// 每个通知将广播给所有订阅的观察员。一对多的关系。
public final class PublishSubject<Element>
    : Observable<Element>
    , SubjectType
    , Cancelable
    , ObserverType
    , SynchronizedUnsubscribeType {
    public typealias SubjectObserverType = PublishSubject<Element>

    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType
    
    /// 是否有观察者
    public var hasObservers: Bool {
        self._lock.lock()
        let count = self._observers.count > 0
        self._lock.unlock()
        return count
    }
    
    private let _lock = RecursiveLock()
    
    // state
    private var _isDisposed = false
    private var _observers = Observers()
    private var _stopped = false
    private var _stoppedEvent = nil as Event<Element>?

    #if DEBUG
        private let _synchronizationTracker = SynchronizationTracker()
    #endif

    /// 是否已处理资源
    public var isDisposed: Bool {
        return self._isDisposed
    }
    
    /// 创建实例
    public override init() {
        super.init()
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }
    
    /// 通知所有订阅的观察者下一个事件。
    ///
    /// - parameter event: 事件发送给观察者。
    public func on(_ event: Event<Element>) {
        #if DEBUG
            self._synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { self._synchronizationTracker.unregister() }
        #endif
        // 将 event 传入所有的 obsvers.on 事件中。
        dispatch(self._synchronized_on(event), event)
    }

    // 获取处理订阅事件的集合
    func _synchronized_on(_ event: Event<Element>) -> Observers {
        self._lock.lock(); defer { self._lock.unlock() }
        switch event {
        case .next:
            if self._isDisposed || self._stopped {
                return Observers()
            }
            
            return self._observers
        case .completed, .error:
            if self._stoppedEvent == nil {
                self._stoppedEvent = event
                self._stopped = true
                let observers = self._observers
                self._observers.removeAll()
                return observers
            }

            return Observers()
        }
    }
    
    /**
    订阅观察者
    
    - parameter observer: 观察者
    - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    */
    public override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        self._lock.lock()
        let subscription = self._synchronized_subscribe(observer)
        self._lock.unlock()
        return subscription
    }

    func _synchronized_subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if let stoppedEvent = self._stoppedEvent {
            observer.on(stoppedEvent)
            return Disposables.create()
        }
        
        if self._isDisposed {
            observer.on(.error(RxError.disposed(object: self)))
            return Disposables.create()
        }
        
        let key = self._observers.insert(observer.on)
        return SubscriptionDisposable(owner: self, key: key)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        self._lock.lock()
        self._synchronized_unsubscribe(disposeKey)
        self._lock.unlock()
    }

    func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        _ = self._observers.removeKey(disposeKey)
    }
    
    /// Returns observer interface for subject.
    public func asObserver() -> PublishSubject<Element> {
        return self
    }
    
    /// Unsubscribe all observers and release resources.
    public func dispose() {
        self._lock.lock()
        self._synchronized_dispose()
        self._lock.unlock()
    }

    final func _synchronized_dispose() {
        self._isDisposed = true
        self._observers.removeAll()
        self._stoppedEvent = nil
    }

    #if TRACE_RESOURCES
        deinit {
            _ = Resources.decrementTotal()
        }
    #endif
}
