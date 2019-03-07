//
//  StartWith.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     将一个值序列加到一个 Observable 序列的前面

     - seealso: [startWith operator on reactivex.io](http://reactivex.io/documentation/operators/startwith.html)

     - parameter elements: 需要添加到指定序列前的元素
     - returns: 以指定值为前缀的新序列
     */
    public func startWith(_ elements: E ...)
        -> Observable<E> {
            return StartWith(source: self.asObservable(), elements: elements)
    }
}

/// Classs: StartWith 继承于 Producer
final private class StartWith<Element>: Producer<Element> {
    let elements: [Element]
    let source: Observable<Element>

    /// 根据给出的源序列和新增值生成一个新的序列
    ///
    /// - Parameters:
    ///   - source: 源序列
    ///   - elements: 新增的值，将被放置在新序列的前部
    init(source: Observable<Element>, elements: [Element]) {
        self.source = source
        self.elements = elements
        super.init()
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        for e in self.elements {
            observer.on(.next(e))
        }

        return (sink: Disposables.create(), subscription: self.source.subscribe(observer))
    }
}
