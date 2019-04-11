//
//  ImmediateSchedulerType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 协议：表示立即执行调度事件的对象
public protocol ImmediateSchedulerType {
    /**
    立即执行 action 事件
    
    - parameter state: 传递给要执行操作的状态。
    - parameter action: 待执行的操作。
    - returns: 用于取消操作的对象。
    */
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable
}

extension ImmediateSchedulerType {
    /**
    调度递归执行的操作
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to execute recursively. The last parameter passed to the action is used to trigger recursive scheduling of the action, passing in recursive invocation state.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public func scheduleRecursive<State>(_ state: State, action: @escaping (_ state: State, _ recurse: (State) -> Void) -> Void) -> Disposable {
        let recursiveScheduler = RecursiveImmediateScheduler(action: action, scheduler: self)
        
        recursiveScheduler.schedule(state)
        
        return Disposables.create(with: recursiveScheduler.dispose)
    }
}
