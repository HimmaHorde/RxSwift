//
//  Timer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType where Element: RxAbstractInteger {
    /**
     创建 Observable 序列每隔一段设定的时间，会发出一个索引数的元素。

        * 它会一直发送
        * 第一次触发事件 == period

     - seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)

     - parameter period: Observable 序列生成值的的间隔事件
     - parameter scheduler: 计时器运行的调度程序.
     - returns: An observable sequence that produces a value after each period.
     */
    public static func interval(_ period: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        return Timer(
            dueTime: period,
            period: period,
            scheduler: scheduler
        )
    }
}

extension ObservableType where Element: RxAbstractInteger {
    /**
     创建 Observable 序列每隔一段设定的时间，会发出一个索引数的元素，可以设置初次执行的时间


     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

     - parameter dueTime: 产生第一个值的时间
     - parameter period: 间隔时间
     - parameter scheduler: Scheduler to run timers on.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
    public static func timer(_ dueTime: RxTimeInterval, period: RxTimeInterval? = nil, scheduler: SchedulerType)
        -> Observable<Element> {
        return Timer(
            dueTime: dueTime,
            period: period,
            scheduler: scheduler
        )
    }
}

import Foundation

final private class TimerSink<Observer: ObserverType> : Sink<Observer> where Observer.Element : RxAbstractInteger  {
    typealias Parent = Timer<Observer.Element>

    private let parent: Parent
    private let lock = RecursiveLock()

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        return self.parent.scheduler.schedulePeriodic(0 as Observer.Element, startAfter: self.parent.dueTime, period: self.parent.period!) { state in
            self.lock.performLocked {
                self.forwardOn(.next(state))
                return state &+ 1
            }
        }
    }
}

final private class TimerOneOffSink<Observer: ObserverType>: Sink<Observer> where Observer.Element: RxAbstractInteger {
    typealias Parent = Timer<Observer.Element>

    private let parent: Parent

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        return self.parent.scheduler.scheduleRelative(self, dueTime: self.parent.dueTime) { [unowned self] _ -> Disposable in
            self.forwardOn(.next(0))
            self.forwardOn(.completed)
            self.dispose()

            return Disposables.create()
        }
    }
}

final private class Timer<Element: RxAbstractInteger>: Producer<Element> {
    fileprivate let scheduler: SchedulerType
    fileprivate let dueTime: RxTimeInterval
    fileprivate let period: RxTimeInterval?

    init(dueTime: RxTimeInterval, period: RxTimeInterval?, scheduler: SchedulerType) {
        self.scheduler = scheduler
        self.dueTime = dueTime
        self.period = period
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        if self.period != nil {
            let sink = TimerSink(parent: self, observer: observer, cancel: cancel)
            let subscription = sink.run()
            return (sink: sink, subscription: subscription)
        }
        else {
            let sink = TimerOneOffSink(parent: self, observer: observer, cancel: cancel)
            let subscription = sink.run()
            return (sink: sink, subscription: subscription)
        }
    }
}
