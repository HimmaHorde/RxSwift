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
    public static func generate(initialState: Element, condition: @escaping (Element) throws -> Bool, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance, iterate: @escaping (Element) throws -> Element) -> Observable<Element> {
        Generate(initialState: initialState, condition: condition, iterate: iterate, resultSelector: { $0 }, scheduler: scheduler)
    }
}

final private class GenerateSink<Sequence, Observer: ObserverType>: Sink<Observer> {
    typealias Parent = Generate<Sequence, Observer.Element>
    
    private let parent: Parent
    
    private var state: Sequence
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        self.state = parent.initialState
        super.init(observer: observer, cancel: cancel)
    }

    /// 发送事件到 Observer
    func run() -> Disposable {
        return self.parent.scheduler.scheduleRecursive(true) { isFirst, recurse -> Void in
            do {
                if !isFirst {
                    self.state = try self.parent.iterate(self.state)
                }
                
                if try self.parent.condition(self.state) {
                    let result = try self.parent.resultSelector(self.state)
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

final private class Generate<Sequence, Element>: Producer<Element> {
    fileprivate let initialState: Sequence
    fileprivate let condition: (Sequence) throws -> Bool
    fileprivate let iterate: (Sequence) throws -> Sequence
    fileprivate let resultSelector: (Sequence) throws -> Element
    fileprivate let scheduler: ImmediateSchedulerType
    
    init(initialState: Sequence, condition: @escaping (Sequence) throws -> Bool, iterate: @escaping (Sequence) throws -> Sequence, resultSelector: @escaping (Sequence) throws -> Element, scheduler: ImmediateSchedulerType) {
        self.initialState = initialState
        self.condition = condition
        self.iterate = iterate
        self.resultSelector = resultSelector
        self.scheduler = scheduler
        super.init()
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = GenerateSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
