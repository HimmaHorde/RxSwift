//
//  Sequence.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 11/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    // MARK: of

    /**
     通过同一类型的可变数量的参数生成 Observable 序列

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - parameter elements: 用来生成 Observable 序列的元素
     - parameter scheduler: 发送元素的调度程序。如果`nil`，元素将在订阅时立即发送.
     - returns: 根据给定元素生成的 Observable 序列。
     */
    public static func of(_ elements: Element ..., scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Element> {
        ObservableSequence(elements: elements, scheduler: scheduler)
    }
}

extension ObservableType {
    /**
     数组转化为 Observable 序列

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
    public static func from(_ array: [Element], scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Element> {
        ObservableSequence(elements: array, scheduler: scheduler)
    }

    /**
     序列转为是 Observable 序列

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
    public static func from<Sequence: Swift.Sequence>(_ sequence: Sequence, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Element> where Sequence.Element == Element {
        ObservableSequence(elements: sequence, scheduler: scheduler)
    }
}

final private class ObservableSequenceSink<Sequence: Swift.Sequence, Observer: ObserverType>: Sink<Observer> where Sequence.Element == Observer.Element {
    typealias Parent = ObservableSequence<Sequence>

    private let parent: Parent

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    // 发送所有事件，complete 之后调用 dispose
    func run() -> Disposable {
        return self.parent.scheduler.scheduleRecursive(self.parent.elements.makeIterator()) { iterator, recurse in
            var mutableIterator = iterator
            if let next = mutableIterator.next() {
                self.forwardOn(.next(next))
                recurse(mutableIterator)
            }
            else {
                self.forwardOn(.completed)
                self.dispose()
            }
        }
    }
}

final private class ObservableSequence<Sequence: Swift.Sequence>: Producer<Sequence.Element> {
    fileprivate let elements: Sequence
    fileprivate let scheduler: ImmediateSchedulerType

    init(elements: Sequence, scheduler: ImmediateSchedulerType) {
        self.elements = elements
        self.scheduler = scheduler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = ObservableSequenceSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
