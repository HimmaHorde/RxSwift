//
//  Map.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     将 Observable 序列的每个元素进行转换。

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: 用于每个源元素转换的函数。
     - returns: 一个可观察的序列，其元素是源元素调转换后结果。

     */
    public func map<Result>(_ transform: @escaping (Element) throws -> Result)
        -> Observable<Result> {
        Map(source: self.asObservable(), transform: transform)
    }
}

final private class MapSink<SourceType, Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Transform = (SourceType) throws -> ResultType

    typealias ResultType = Observer.Element 
    typealias Element = SourceType

    private let transform: Transform

    init(transform: @escaping Transform, observer: Observer, cancel: Cancelable) {
        self.transform = transform
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceType>) {
        switch event {
        case .next(let element):
            do {
                let mappedElement = try self.transform(element)
                self.forwardOn(.next(mappedElement))
            }
            catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case .error(let error):
            self.forwardOn(.error(error))
            self.dispose()
        case .completed:
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final private class Map<SourceType, ResultType>: Producer<ResultType> {
    typealias Transform = (SourceType) throws -> ResultType

    private let source: Observable<SourceType>

    private let transform: Transform

    init(source: Observable<SourceType>, transform: @escaping Transform) {
        self.source = source
        self.transform = transform
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == ResultType {
        let sink = MapSink(transform: self.transform, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
