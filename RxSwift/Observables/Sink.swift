//
//  Sink.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Sink 持有 ObserverType ，Cancelable ；
/// > dispose() 执行事调用 Cancelable 的 dispose() 方法，取消对 Cancelable 的引用。
class Sink<Observer: ObserverType> : Disposable {
    fileprivate let _observer: Observer
    fileprivate let _cancel: Cancelable
    private let _disposed = AtomicInt(0)

    #if DEBUG
        private let _synchronizationTracker = SynchronizationTracker()
    #endif

    init(observer: Observer, cancel: Cancelable) {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
        self._observer = observer
        self._cancel = cancel
    }

    /// 调用 observer.on 方法处理事件，当 dispose() 方法被调用后不在响应事件。
    ///
    /// - Parameter event: 事件
    final func forwardOn(_ event: Event<Observer.Element>) {
        #if DEBUG
            self._synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { self._synchronizationTracker.unregister() }
        #endif
        if isFlagSet(self._disposed, 1) {
            return
        }
        self._observer.on(event)
    }

    final func forwarder() -> SinkForward<Observer> {
        return SinkForward(forward: self)
    }

    final var disposed: Bool {
        return isFlagSet(self._disposed, 1)
    }

    func dispose() {
        fetchOr(self._disposed, 1)
        self._cancel.dispose()
    }

    deinit {
#if TRACE_RESOURCES
       _ =  Resources.decrementTotal()
#endif
    }
}

final class SinkForward<Observer: ObserverType>: ObserverType {
    typealias Element = Observer.Element 

    private let _forward: Sink<Observer>

    init(forward: Sink<Observer>) {
        self._forward = forward
    }

    final func on(_ event: Event<Element>) {
        switch event {
        case .next:
            self._forward._observer.on(event)
        case .error, .completed:
            self._forward._observer.on(event)
            self._forward._cancel.dispose()
        }
    }
}
