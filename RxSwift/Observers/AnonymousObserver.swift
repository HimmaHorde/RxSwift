//
//  AnonymousObserver.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

final class AnonymousObserver<Element>: ObserverBase<Element> {
    typealias EventHandler = (Event<Element>) -> Void
    
    private let _eventHandler : EventHandler
    
    init(_ eventHandler: @escaping EventHandler) {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
        self._eventHandler = eventHandler
    }

    // on 方法调用此方法处理事件
    override func onCore(_ event: Event<Element>) {
        return self._eventHandler(event)
    }
    
#if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
#endif
}
