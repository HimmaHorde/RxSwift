//
//  Binder.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 9/17/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/**
 执行接口绑定规则的观察者:
 * 不能绑定 errors (Debug 会`fatalError` ，release 会打印错误日志)
 * 确保绑定在特定的调度程序上执行

 `Binder` 不会强引用 target，如果 target 被释放，元素不会被绑定。

 在主线程观察订阅事件
 */
public struct Binder<Value>: ObserverType {
    public typealias Element = Value
    
    private let _binding: (Event<Value>) -> Void

    /// Initializes `Binder`
    ///
    /// - parameter target: Target object.
    /// - parameter scheduler: Scheduler used to bind the events.
    /// - parameter binding: Binding logic.
    public init<Target: AnyObject>(_ target: Target, scheduler: ImmediateSchedulerType = MainScheduler(), binding: @escaping (Target, Value) -> Void) {
        weak var weakTarget = target

        self._binding = { event in
            switch event {
            case .next(let element):
                _ = scheduler.schedule(element) { element in
                    if let target = weakTarget {
                        binding(target, element)
                    }
                    return Disposables.create()
                }
            case .error(let error):
                bindingError(error)
            case .completed:
                break
            }
        }
    }

    /// Binds next element to owner view as described in `binding`.
    public func on(_ event: Event<Value>) {
        self._binding(event)
    }

    /// Erases type of observer.
    ///
    /// - returns: type erased observer.
    public func asObserver() -> AnyObserver<Value> {
        return AnyObserver(eventHandler: self.on)
    }
}
