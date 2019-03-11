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
    public static func of(_ elements: E ..., scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<E> {
        return ObservableSequence(elements: elements, scheduler: scheduler)
    }
}

extension ObservableType {
    /**
     数组转化为 Observable 序列

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
    public static func from(_ array: [E], scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<E> {
        return ObservableSequence(elements: array, scheduler: scheduler)
    }

    /**
     序列转为是 Observable 序列

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
    public static func from<S: Sequence>(_ sequence: S, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<E> where S.Iterator.Element == E {
        return ObservableSequence(elements: sequence, scheduler: scheduler)
    }
}

final private class ObservableSequenceSink<S: Sequence, O: ObserverType>: Sink<O> where S.Iterator.Element == O.E {
    typealias Parent = ObservableSequence<S>

    private let _parent: Parent

    init(parent: Parent, observer: O, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    // 发送所有事件，complete 之后调用 dispose
    func run() -> Disposable {
        return self._parent._scheduler.scheduleRecursive(self._parent._elements.makeIterator()) { iterator, recurse in
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

final private class ObservableSequence<S: Sequence>: Producer<S.Iterator.Element> {
    fileprivate let _elements: S
    fileprivate let _scheduler: ImmediateSchedulerType

    init(elements: S, scheduler: ImmediateSchedulerType) {
        self._elements = elements
        self._scheduler = scheduler
    }

    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == E {
        let sink = ObservableSequenceSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
