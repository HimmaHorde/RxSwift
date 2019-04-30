//
//  SchedulerType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import enum Dispatch.DispatchTimeInterval
import struct Foundation.Date

// Type that represents time interval in the context of RxSwift.
public typealias RxTimeInterval = DispatchTimeInterval

/// Rx的日期类型 = Date
public typealias RxTime = Date

/// 表示调度工作单元的对象
public protocol SchedulerType: ImmediateSchedulerType {

    /// 当前时间
    var now : RxTime { get }

    /**
    延迟调度要执行的操作。
    
    - parameter state: State passed to the action to be executed.
    - parameter dueTime: Relative time after which to execute the action.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    func scheduleRelative<StateType>(_ state: StateType, dueTime: RxTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable
 
    /**
    调度要定时执行的操作。
    
    - parameter state: State passed to the action to be executed.
    - parameter startAfter: Period after which initial work should be run.
    - parameter period: Period for running the work periodically.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable
}

extension SchedulerType {

    /**
    使用递归调度模拟周期性任务。

    - parameter state: Initial state passed to the action upon the first iteration.
    - parameter startAfter: Period after which initial work should be run.
    - parameter period: Period for running the work periodically.
    - returns: The disposable object used to cancel the scheduled recurring action (best effort).
    */
    public func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        let schedule = SchedulePeriodicRecursive(scheduler: self, startAfter: startAfter, period: period, action: action, state: state)
            
        return schedule.start()
    }

    /// 默认：递归锁操作
    func scheduleRecursive<State>(_ state: State, dueTime: RxTimeInterval, action: @escaping (State, AnyRecursiveScheduler<State>) -> Void) -> Disposable {
        let scheduler = AnyRecursiveScheduler(scheduler: self, action: action)
         
        scheduler.schedule(state, dueTime: dueTime)
            
        return Disposables.create(with: scheduler.dispose)
    }
}
