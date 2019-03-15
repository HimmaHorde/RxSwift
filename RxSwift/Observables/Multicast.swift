//
//  Multicast.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/**
 对可观察序列进行包装，该包装器可以与其底层可观察序列连接或断开连接。
 */
public class ConnectableObservable<Element>
    : Observable<Element>
    , ConnectableObservableType {

    /**
     将可观察包装器连接到它的源。只要建立了连接，所有订阅的观察者都将接收来自底层可观察序列的值。

     - returns: Disposable used to disconnect the observable wrapper from its source, causing subscribed observer to stop receiving values from the underlying observable sequence.
     */
    public func connect() -> Disposable {
        rxAbstractMethod()
    }
}

extension ObservableType {

    /**
    Multicasts the source sequence notifications through an instantiated subject into all uses of the sequence within a selector function.

    Each subscription to the resulting sequence causes a separate multicast invocation, exposing the sequence resulting from the selector function's invocation.

    For specializations with fixed subject types, see `publish` and `replay`.

    - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

    - parameter subjectSelector: Factory function to create an intermediate subject through which the source sequence's elements will be multicast to the selector function.
    - parameter selector: Selector function which can use the multicasted source sequence subject to the policies enforced by the created subject.
    - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence within a selector function.
    */
    public func multicast<S: SubjectType, R>(_ subjectSelector: @escaping () throws -> S, selector: @escaping (Observable<S.E>) throws -> Observable<R>)
        -> Observable<R> where S.SubjectObserverType.E == E {
        return Multicast(
            source: self.asObservable(),
            subjectSelector: subjectSelector,
            selector: selector
        )
    }
}

extension ObservableType {

    /**
     返回一个可连接的可观察序列，对观察者共享同一个订阅源

     相当于 `PublishSubject` 对象加上一个可连接控制(.connect()方法)。

    - seealso: [publish operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

    - returns: 可连接的可观察序列
    */
    public func publish() -> ConnectableObservable<E> {
        return self.multicast { PublishSubject() }
    }
}

extension ObservableType {

    /**
     返回一个可连接的可观察序列，对观察者共享同一个序列源和缓存

     相当于 `ReplaySubject` 对象加上一个可连接控制(.connect()方法)。

     - seealso: [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - parameter bufferSize: 重播缓冲区的最大元素数。
     - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
     */
    public func replay(_ bufferSize: Int)
        -> ConnectableObservable<E> {
        return self.multicast { ReplaySubject.create(bufferSize: bufferSize) }
    }

    /**
     Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying all elements.

     This operator is a specialization of `multicast` using a `ReplaySubject`.

     - seealso: [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
     */
    public func replayAll()
        -> ConnectableObservable<E> {
        return self.multicast { ReplaySubject.createUnbounded() }
    }
}

extension ConnectableObservableType {

    /**
    Returns an observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.

    - seealso: [refCount operator on reactivex.io](http://reactivex.io/documentation/operators/refcount.html)

    - returns: An observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.
    */
    public func refCount() -> Observable<E> {
        return RefCount(source: self)
    }
}

extension ObservableType {

    /**
     multicast 方法将一个正常的序列转换成一个可连接的序列。
     同时 multicast 方法还可以传入一个 Subject，每当序列发送事件时都会触发这个 Subject 的发送。

     Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.

     For specializations with fixed subject types, see `publish` and `replay`.

     - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

     - parameter subject: Subject to push source elements into.
     - returns: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
     */
    public func multicast<S: SubjectType>(_ subject: S)
        -> ConnectableObservable<S.E> where S.SubjectObserverType.E == E {
        return ConnectableObservableAdapter(source: self.asObservable(), makeSubject: { subject })
    }

    /**
     multicast 方法将一个正常的序列转换成一个可连接的序列。
     同时 multicast 方法还可以传入一个 Subject，每当序列发送事件时都会触发这个 Subject 的发送。

     Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.

     Subject is cleared on connection disposal or in case source sequence produces terminal event.

     - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

     - parameter makeSubject: Factory function used to instantiate a subject for each connection.
     - returns: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
     */
    public func multicast<S: SubjectType>(makeSubject: @escaping () -> S)
        -> ConnectableObservable<S.E> where S.SubjectObserverType.E == E {
        return ConnectableObservableAdapter(source: self.asObservable(), makeSubject: makeSubject)
    }
}

/// on 事件调用 subject.on
final private class Connection<S: SubjectType>: ObserverType, Disposable {
    typealias E = S.SubjectObserverType.E

    private var _lock: RecursiveLock
    // state
    private var _parent: ConnectableObservableAdapter<S>?
    private var _subscription : Disposable?
    private var _subjectObserver: S.SubjectObserverType

    private var _disposed = AtomicInt(0)


    /// 传入 connect 适配器，subject 的 观察者
    init(parent: ConnectableObservableAdapter<S>, subjectObserver: S.SubjectObserverType, lock: RecursiveLock, subscription: Disposable) {
        self._parent = parent
        self._subscription = subscription
        self._lock = lock
        self._subjectObserver = subjectObserver
    }

    /// 调用 subject.on
    func on(_ event: Event<S.SubjectObserverType.E>) {
        if isFlagSet(&self._disposed, 1) {
            return
        }
        if event.isStopEvent {
            self.dispose()
        }
        self._subjectObserver.on(event)
    }

    func dispose() {
        _lock.lock(); defer { _lock.unlock() } // {
        fetchOr(&self._disposed, 1)
        guard let parent = _parent else {
            return
        }

        if parent._connection === self {
            parent._connection = nil
            parent._subject = nil
        }
        self._parent = nil

        self._subscription?.dispose()
        self._subscription = nil
        // }
    }
}

/// 可连接序列适配器
/// > 实现 connect 方法
final private class ConnectableObservableAdapter<S: SubjectType>
    : ConnectableObservable<S.E> {
    typealias ConnectionType = Connection<S>

    fileprivate let _source: Observable<S.SubjectObserverType.E>
    fileprivate let _makeSubject: () -> S

    fileprivate let _lock = RecursiveLock()
    fileprivate var _subject: S?

    // state
    fileprivate var _connection: ConnectionType?

    /// 初始化，此时未生成 subject 对象和 connection 对象
    ///
    /// - Parameters:
    ///   - source: 可观察序列
    ///   - makeSubject: 生成 subject 的闭包
    init(source: Observable<S.SubjectObserverType.E>, makeSubject: @escaping () -> S) {
        self._source = source
        self._makeSubject = makeSubject
        self._subject = nil
        self._connection = nil
    }

    /// 如果 connection 对象存在，直接返回对象。立刻创建，并使用此对象订阅源可订阅序列。
    ///
    /// connection，本身是观察者，也是资管管理者。
    /// 此方法被调用时源序列猜真正被订阅，订阅者是 subject.asObserver()。
    /// - Returns: connection 对象
    override func connect() -> Disposable {
        return self._lock.calculateLocked {
            if let connection = self._connection {
                return connection
            }

            let singleAssignmentDisposable = SingleAssignmentDisposable()
            let connection = Connection(parent: self, subjectObserver: self.lazySubject.asObserver(), lock: self._lock, subscription: singleAssignmentDisposable)
            self._connection = connection
            let subscription = self._source.subscribe(connection)
            singleAssignmentDisposable.setDisposable(subscription)
            return connection
        }
    }

    /// 返回 subject 对象，如果不存在生成 subject 对象。
    fileprivate var lazySubject: S {
        if let subject = self._subject {
            return subject
        }

        let subject = self._makeSubject()
        self._subject = subject
        return subject
    }


    /// 调用 subject.subscribe
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == S.E {
        return self.lazySubject.subscribe(observer)
    }
}

final private class RefCountSink<CO: ConnectableObservableType, O: ObserverType>
    : Sink<O>
    , ObserverType where CO.E == O.E {
    typealias Element = O.E
    typealias Parent = RefCount<CO>

    private let _parent: Parent

    private var _connectionIdSnapshot: Int64 = -1

    init(parent: Parent, observer: O, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        let subscription = self._parent._source.subscribe(self)
        self._parent._lock.lock(); defer { self._parent._lock.unlock() } // {

        self._connectionIdSnapshot = self._parent._connectionId

        if self.disposed {
            return Disposables.create()
        }

        if self._parent._count == 0 {
            self._parent._count = 1
            self._parent._connectableSubscription = self._parent._source.connect()
        }
        else {
            self._parent._count += 1
        }
        // }

        return Disposables.create {
            subscription.dispose()
            self._parent._lock.lock(); defer { self._parent._lock.unlock() } // {
            if self._parent._connectionId != self._connectionIdSnapshot {
                return
            }
            if self._parent._count == 1 {
                self._parent._count = 0
                guard let connectableSubscription = self._parent._connectableSubscription else {
                    return
                }

                connectableSubscription.dispose()
                self._parent._connectableSubscription = nil
            }
            else if self._parent._count > 1 {
                self._parent._count -= 1
            }
            else {
                rxFatalError("Something went wrong with RefCount disposing mechanism")
            }
            // }
        }
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            self.forwardOn(event)
        case .error, .completed:
            self._parent._lock.lock() // {
                if self._parent._connectionId == self._connectionIdSnapshot {
                    let connection = self._parent._connectableSubscription
                    defer { connection?.dispose() }
                    self._parent._count = 0
                    self._parent._connectionId = self._parent._connectionId &+ 1
                    self._parent._connectableSubscription = nil
                }
            // }
            self._parent._lock.unlock()
            self.forwardOn(event)
            self.dispose()
        }
    }
}


/// 可连接序列降级为普通序列
final private class RefCount<CO: ConnectableObservableType>: Producer<CO.E> {
    fileprivate let _lock = RecursiveLock()

    // state
    fileprivate var _count = 0
    fileprivate var _connectionId: Int64 = 0
    fileprivate var _connectableSubscription = nil as Disposable?

    fileprivate let _source: CO

    init(source: CO) {
        self._source = source
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == CO.E {
        let sink = RefCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class MulticastSink<S: SubjectType, O: ObserverType>: Sink<O>, ObserverType {
    typealias Element = O.E
    typealias ResultType = Element
    typealias MutlicastType = Multicast<S, O.E>

    private let _parent: MutlicastType

    init(parent: MutlicastType, observer: O, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        do {
            let subject = try self._parent._subjectSelector()
            let connectable = ConnectableObservableAdapter(source: self._parent._source, makeSubject: { subject })

            let observable = try self._parent._selector(connectable)

            let subscription = observable.subscribe(self)
            let connection = connectable.connect()

            return Disposables.create(subscription, connection)
        }
        catch let e {
            self.forwardOn(.error(e))
            self.dispose()
            return Disposables.create()
        }
    }

    func on(_ event: Event<ResultType>) {
        self.forwardOn(event)
        switch event {
        case .next: break
        case .error, .completed:
            self.dispose()
        }
    }
}

final private class Multicast<S: SubjectType, R>: Producer<R> {
    /// Subject 生成类
    typealias SubjectSelectorType = () throws -> S
    typealias SelectorType = (Observable<S.E>) throws -> Observable<R>

    fileprivate let _source: Observable<S.SubjectObserverType.E>
    fileprivate let _subjectSelector: SubjectSelectorType
    fileprivate let _selector: SelectorType

    init(source: Observable<S.SubjectObserverType.E>, subjectSelector: @escaping SubjectSelectorType, selector: @escaping SelectorType) {
        self._source = source
        self._subjectSelector = subjectSelector
        self._selector = selector
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == R {
        let sink = MulticastSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
