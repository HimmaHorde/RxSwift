//
//  ConcurrentDispatchQueueScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.TimeInterval
import Dispatch

/// 抽象指定队列`dispatch_queue_t`上执行的任务，你也可以传递一个串行队列，它应该不会造成任何问题。
///
/// 当需要在后台执行某些任务时，这个调度器是最合适的。
public class ConcurrentDispatchQueueScheduler: SchedulerType {
    public typealias TimeInterval = Foundation.TimeInterval
    public typealias Time = Date
    
    public var now : Date {
        return Date()
    }

    let configuration: DispatchQueueConfiguration
    
    /// 构造新的`ConcurrentDispatchQueueScheduler`，它包装了`DispatchQueue`。
    ///
    /// - parameter queue: 目标调度队列。
    /// - parameter leeway: 系统延迟计时器的时间(以纳秒为单位)。
    public init(queue: DispatchQueue, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        self.configuration = DispatchQueueConfiguration(queue: queue, leeway: leeway)
    }
    
    /// 快速初始化方法，其中封装了一个全局并发调度队列。
    ///
    /// - parameter qos: 目标全局调度队列，按指定的优先级创建。
    /// - parameter leeway: 系统延迟计时器的时间(以纳秒为单位)。
    @available(iOS 8, OSX 10.10, *)
    public convenience init(qos: DispatchQoS, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        self.init(queue: DispatchQueue(
            label: "rxswift.queue.\(qos)",
            qos: qos,
            attributes: [DispatchQueue.Attributes.concurrent],
            target: nil),
            leeway: leeway
        )
    }

    /**
    调度要立即执行的操作。
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public final func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        return self.configuration.schedule(state, action: action)
    }
    
    /**
    调度延迟执行的操作。
    
    - parameter state: State passed to the action to be executed.
    - parameter dueTime: Relative time after which to execute the action.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public final func scheduleRelative<StateType>(_ state: StateType, dueTime: RxTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        return self.configuration.scheduleRelative(state, dueTime: dueTime, action: action)
    }
    
    /**
    定时执行任务。
    
    - parameter state: State passed to the action to be executed.
    - parameter startAfter: Period after which initial work should be run.
    - parameter period: Period for running the work periodically.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        return self.configuration.schedulePeriodic(state, startAfter: startAfter, period: period, action: action)
    }
}
