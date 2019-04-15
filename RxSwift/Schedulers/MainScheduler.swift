//
//  MainScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Dispatch
#if !os(Linux)
    import Foundation
#endif

/**
抽象需要在主队列运行的`DispatchQueue.main`的工作. 如果调度使用主队列`DispatchQueue.main`，则立即执行。

 - 这个调度程序通常用于执行 UI 相关任务。
 - 主调度是一个特殊的串行队列调度`SerialDispatchQueueScheduler` .

 这个调度程序是为`observeOn`操作符优化的。为了确保 `subscribeOn` 在主线程上调用，请使用 `ConcurrentMainScheduler`(专门为其做了优化)
*/
public final class MainScheduler : SerialDispatchQueueScheduler {

    // 主队列
    private let _mainQueue: DispatchQueue

    // 队列内任务的数量
    let numberEnqueued = AtomicInt(0)

    /// 根据 `DispatchQueue.main` 生成 `MainScheduler` 实例。
    public init() {
        self._mainQueue = DispatchQueue.main
        super.init(serialQueue: self._mainQueue)
    }

    /// `MainScheduler` 单例
    public static let instance = MainScheduler()

    /// `MainScheduler` 单例总是执行异步操作
    /// 不优化主队列执行操作
    public static let asyncInstance = SerialDispatchQueueScheduler(serialQueue: DispatchQueue.main)

    /// 判断是否在主线程运行，后台线程会抛出错误。
    public class func ensureExecutingOnScheduler(errorMessage: String? = nil) {
        if !DispatchQueue.isMain {
            rxFatalError(errorMessage ?? "Executing on background thread. Please use `MainScheduler.instance.schedule` to schedule work on main thread.")
        }
    }

    /// 判断是否在主线程运行，后台线程会抛出错误。
    public class func ensureRunningOnMainThread(errorMessage: String? = nil) {
        #if !os(Linux) // isMainThread is not implemented in Linux Foundation
            guard Thread.isMainThread else {
                rxFatalError(errorMessage ?? "Running on background thread.")
            }
        #endif
    }

    // 将任务放入主队列并执行
    override func scheduleInternal<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        // 队列任务数量 + 1
        let previousNumberEnqueued = increment(self.numberEnqueued)

        // 如果之前无任务，直接执行 action 并结束
        if DispatchQueue.isMain && previousNumberEnqueued == 0 {
            let disposable = action(state)
            decrement(self.numberEnqueued)
            return disposable
        }

        let cancel = SingleAssignmentDisposable()

        self._mainQueue.async {
            if !cancel.isDisposed {
                _ = action(state)
            }

            decrement(self.numberEnqueued)
        }

        return cancel
    }
}
