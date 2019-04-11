//
//  Producer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


/// class: 继承于 Observable 类型，定义了关键方法 run（子类需要重写）。
class Producer<Element> : Observable<Element> {
    override init() {
        super.init()
    }


    /// 实现 Observable 中 subscribe 方法
    ///
    /// - Parameter observer: 观察者/订阅者
    /// - Returns: 实现 Disposable 协议的对象
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        if !CurrentThreadScheduler.isScheduleRequired {
            // 返回的一次性引用需要在处理后释放所有引用
            let disposer = SinkDisposer()
            let sinkAndSubscription = self.run(observer, cancel: disposer)
            disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

            return disposer
        } else {
            return CurrentThreadScheduler.instance.schedule(()) { _ in
                let disposer = SinkDisposer()
                let sinkAndSubscription = self.run(observer, cancel: disposer)
                disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

                return disposer
            }
        }
    }


    /// Producer 核心函数，子类需重写。
    ///
    /// - Parameters:
    ///   - observer: 观察者
    ///   - cancel:
    func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        rxAbstractMethod()
    }
}


/// 管理 sink 类的资源管理器
fileprivate final class SinkDisposer: Cancelable {
    fileprivate enum DisposeState: Int32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }

    /// 0：初始状态, 2：设置接收器和订阅，3：已释放 ，1：未 set 调用了释放，要求 set 时立即释放。
    private let _state = AtomicInt(0)
    private var _sink: Disposable?
    private var _subscription: Disposable?

    var isDisposed: Bool {
        return isFlagSet(self._state, DisposeState.disposed.rawValue)
    }

    func setSinkAndSubscription(sink: Disposable, subscription: Disposable) {
        self._sink = sink
        self._subscription = subscription

        // _state = 0 -> _state = 2, previousState = 0
        // _state = 2 -> _state = 2, previousState = 2
        // _state = 3 -> _state = 3, previousState = 3
        // _state 值变为 2 ，表示已设置 Sink 和 Subscription
        let previousState = fetchOr(self._state, DisposeState.sinkAndSubscriptionSet.rawValue)

        // 0 & 2 = 0
        // 2 & 2 = 2
        // 3 & 2 = 2
        // 重复设置，抛出错误。只允许一次。
        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            rxFatalError("Sink and subscription were already set")
        }

        // 1 的与运算，结果为 1 或者 0
        // 当 previousState = 1 -> 1
        // 未设置之前释放，_state = 1 , 立即释放资源 。
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            sink.dispose()
            subscription.dispose()
            self._sink = nil
            self._subscription = nil
        }
    }

    func dispose() {
        // 未设置 sink ，_state = 0 -> 1
        // 正常 set 之后，_state = 2 -> 3
        // 释放之后 _state = 3
        let previousState = fetchOr(self._state, DisposeState.disposed.rawValue)

        // previousState = 2 ,previousState = 0 可跳过此判断。
        // 只要之前未执行过 dispose() 就可以继续往下走。
        // 防止重复释放
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }

        // 仅 previousState = 2 ，也就是设置过 sink 之后才能释放
        // 当 previousState = 0 ，未设置 sink 不需要释放，等待用户设置 sink 时直接释放
        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            guard let sink = self._sink else {
                rxFatalError("Sink not set")
            }
            guard let subscription = self._subscription else {
                rxFatalError("Subscription not set")
            }

            sink.dispose()
            subscription.dispose()

            self._sink = nil
            self._subscription = nil
        }
    }
}
