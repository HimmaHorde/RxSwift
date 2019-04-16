//
//  Deprecated.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/**
 These methods are conceptually extensions of `XCTestCase` but because referencing them in closures would
 require specifying `self.*`, they are made global.
 */
//extension XCTestCase {
    /**
     Factory method for an `.next` event recorded at a given time with a given value.
 
     - parameter time: Recorded virtual time the `.next` event occurs.
     - parameter element: Next sequence element.
     - returns: Recorded event in time.
     */
    public func next<T>(_ time: TestTime, _ element: T) -> Recorded<Event<T>> {
        #if DEBUG
            DeprecationWarner.warnIfNeeded(.globalTestFunctionNext)
        #endif
        return Recorded.next(time, element)
    }

    /**
     Factory method for an `.completed` event recorded at a given time.
 
     - parameter time: Recorded virtual time the `.completed` event occurs.
     - parameter type: Sequence elements type.
     - returns: Recorded event in time.
     */
    public func completed<T>(_ time: TestTime, _ type: T.Type = T.self) -> Recorded<Event<T>> {
        #if DEBUG
            DeprecationWarner.warnIfNeeded(.globalTestFunctionCompleted)
        #endif
        return Recorded.completed(time, type)
    }

    /**
     Factory method for an `.error` event recorded at a given time with a given error.
 
     - parameter time: Recorded virtual time the `.completed` event occurs.
     */
    public func error<T>(_ time: TestTime, _ error: Swift.Error, _ type: T.Type = T.self) -> Recorded<Event<T>> {
        #if DEBUG
            DeprecationWarner.warnIfNeeded(.globalTestFunctionError)
        #endif
        return Recorded.error(time, error, type)
    }
//}
