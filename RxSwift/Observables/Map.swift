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
    public func map<R>(_ transform: @escaping (E) throws -> R)
        -> Observable<R> {
        return self.asObservable().composeMap(transform)
    }
}

final private class MapSink<SourceType, O: ObserverType>: Sink<O>, ObserverType {
    typealias Transform = (SourceType) throws -> ResultType

    typealias ResultType = O.E
    typealias Element = SourceType

    private let _transform: Transform

    init(transform: @escaping Transform, observer: O, cancel: Cancelable) {
        self._transform = transform
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceType>) {
        switch event {
        case .next(let element):
            do {
                let mappedElement = try self._transform(element)
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

#if TRACE_RESOURCES
    fileprivate let _numberOfMapOperators = AtomicInt(0)
    extension Resources {
        public static var numberOfMapOperators: Int32 {
            return load(_numberOfMapOperators)
        }
    }
#endif

internal func _map<Element, R>(source: Observable<Element>, transform: @escaping (Element) throws -> R) -> Observable<R> {
    return Map(source: source, transform: transform)
}

final private class Map<SourceType, ResultType>: Producer<ResultType> {
    typealias Transform = (SourceType) throws -> ResultType

    private let _source: Observable<SourceType>

    private let _transform: Transform

    init(source: Observable<SourceType>, transform: @escaping Transform) {
        self._source = source
        self._transform = transform

#if TRACE_RESOURCES
        _ = increment(_numberOfMapOperators)
#endif
    }

    override func composeMap<R>(_ selector: @escaping (ResultType) throws -> R) -> Observable<R> {
        let originalSelector = self._transform
        return Map<SourceType, R>(source: self._source, transform: { (s: SourceType) throws -> R in
            let r: ResultType = try originalSelector(s)
            return try selector(r)
        })
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == ResultType {
        let sink = MapSink(transform: self._transform, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }

    #if TRACE_RESOURCES
    deinit {
        _ = decrement(_numberOfMapOperators)
    }
    #endif
}
