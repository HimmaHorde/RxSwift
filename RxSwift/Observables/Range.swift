//
//  Range.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType where Element: RxAbstractInteger {
    /**
     该方法通过指定起始和结束数值，创建一个以这个范围内所有值作为初始值的 Observable 序列。

         //使用range()
         let observable = Observable.range(start: 1, count: 5)
         //使用of()
         let observable = Observable.of(1, 2, 3 ,4 ,5)

     - seealso: [range operator on reactivex.io](http://reactivex.io/documentation/operators/range.html)

     - parameter start: 连续整数序列的第一个值
     - parameter count: 连续序列的元素个数
     - parameter scheduler: 生成 Observable 序列的调度程序
     - returns: 包含一系列连序整数的 Observable 序列。
     */
    public static func range(start: Element, count: Element, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Element> {
        RangeProducer<Element>(start: start, count: count, scheduler: scheduler)
    }
}

final private class RangeProducer<Element: RxAbstractInteger>: Producer<Element> {
    fileprivate let start: Element
    fileprivate let count: Element
    fileprivate let scheduler: ImmediateSchedulerType

    init(start: Element, count: Element, scheduler: ImmediateSchedulerType) {
        guard count >= 0 else {
            rxFatalError("count can't be negative")
        }

        guard start &+ (count - 1) >= start || count == 0 else {
            rxFatalError("overflow of count")
        }

        self.start = start
        self.count = count
        self.scheduler = scheduler
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = RangeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class RangeSink<Observer: ObserverType>: Sink<Observer> where Observer.Element: RxAbstractInteger {
    typealias Parent = RangeProducer<Observer.Element>
    
    private let parent: Parent
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return self.parent.scheduler.scheduleRecursive(0 as Observer.Element) { i, recurse in
            if i < self.parent.count {
                self.forwardOn(.next(self.parent.start + i))
                recurse(i + 1)
            }
            else {
                self.forwardOn(.completed)
                self.dispose()
            }
        }
    }
}
