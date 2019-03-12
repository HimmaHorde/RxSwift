//
//  Generate.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     通过指定方法生成元素，当元素不符合预设调制时 `complete`。

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter initialState: 初始状态.
     - parameter condition: 判断条件 == false 结束
     - parameter iterate: 值的迭代方法（生成新值的方法）
     - parameter scheduler: 调度程序 Scheduler
     - returns: 生成的序列
     */
    public static func generate(initialState: E, condition: @escaping (E) throws -> Bool, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance, iterate: @escaping (E) throws -> E) -> Observable<E> {
        return Generate(initialState: initialState, condition: condition, iterate: iterate, resultSelector: { $0 }, scheduler: scheduler)
    }
}

final private class GenerateSink<S, O: ObserverType>: Sink<O> {
    typealias Parent = Generate<S, O.E>
    
    private let _parent: Parent
    
    private var _state: S
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        self._parent = parent
        self._state = parent._initialState
        super.init(observer: observer, cancel: cancel)
    }

    /// 发送事件到 Observer
    func run() -> Disposable {
        return self._parent._scheduler.scheduleRecursive(true) { isFirst, recurse -> Void in
            do {
                if !isFirst {
                    self._state = try self._parent._iterate(self._state)
                }
                
                if try self._parent._condition(self._state) {
                    let result = try self._parent._resultSelector(self._state)
                    self.forwardOn(.next(result))
                    
                    recurse(false)
                }
                else {
                    self.forwardOn(.completed)
                    self.dispose()
                }
            }
            catch let error {
                self.forwardOn(.error(error))
                self.dispose()
            }
        }
    }
}

final private class Generate<S, E>: Producer<E> {
    fileprivate let _initialState: S
    fileprivate let _condition: (S) throws -> Bool
    fileprivate let _iterate: (S) throws -> S
    fileprivate let _resultSelector: (S) throws -> E
    fileprivate let _scheduler: ImmediateSchedulerType
    
    init(initialState: S, condition: @escaping (S) throws -> Bool, iterate: @escaping (S) throws -> S, resultSelector: @escaping (S) throws -> E, scheduler: ImmediateSchedulerType) {
        self._initialState = initialState
        self._condition = condition
        self._iterate = iterate
        self._resultSelector = resultSelector
        self._scheduler = scheduler
        super.init()
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == E {
        let sink = GenerateSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
