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

This scheduler is optimized for `observeOn` operator. To ensure observable sequence is subscribed on main thread using `subscribeOn`
operator please use `ConcurrentMainScheduler` because it is more optimized for that purpose.
*/
public final class MainScheduler : SerialDispatchQueueScheduler {

    private let _mainQueue: DispatchQueue

    let numberEnqueued = AtomicInt(0)

    /// Initializes new instance of `MainScheduler`.
    public init() {
        self._mainQueue = DispatchQueue.main
        super.init(serialQueue: self._mainQueue)
    }

    /// Singleton instance of `MainScheduler`
    public static let instance = MainScheduler()

    /// Singleton instance of `MainScheduler` that always schedules work asynchronously
    /// and doesn't perform optimizations for calls scheduled from main queue.
    public static let asyncInstance = SerialDispatchQueueScheduler(serialQueue: DispatchQueue.main)

    /// In case this method is called on a background thread it will throw an exception.
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

    override func scheduleInternal<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let previousNumberEnqueued = increment(self.numberEnqueued)

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
