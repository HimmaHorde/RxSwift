//
//  RecursiveScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


/// 队列状态
///
/// - initial: 初始
/// - added: 添加中
/// - done: 完成
private enum ScheduleState {
    case initial
    case added(CompositeDisposable.DisposeKey)
    case done
}

/// 加递归锁，执行操作。
final class AnyRecursiveScheduler<State> {
    
    typealias Action =  (State, AnyRecursiveScheduler<State>) -> Void

    // 递归锁
    private let _lock = RecursiveLock()
    
    // state
    private let _group = CompositeDisposable()

    private var _scheduler: SchedulerType
    private var _action: Action?
    
    init(scheduler: SchedulerType, action: @escaping Action) {
        self._action = action
        self._scheduler = scheduler
    }

    /**
    调度递归执行的操作。
    
    - parameter state: 状态传递给要执行的操作。
    - parameter dueTime: 执行递归操作后的相对时间。
    */
    func schedule(_ state: State, dueTime: RxTimeInterval) {
        var scheduleState: ScheduleState = .initial

        let d = self._scheduler.scheduleRelative(state, dueTime: dueTime) { state -> Disposable in
            // best effort
            if self._group.isDisposed {
                return Disposables.create()
            }

            // 给 action 加锁
            let action = self._lock.calculateLocked { () -> Action? in
                switch scheduleState {
                case let .added(removeKey):
                    self._group.remove(for: removeKey)
                case .initial:
                    break
                case .done:
                    break
                }

                scheduleState = .done

                return self._action
            }

            /// 递归指定 action
            if let action = action {
                action(state, self)
            }
            
            return Disposables.create()
        }
            
        self._lock.performLocked {
            switch scheduleState {
            case .added:
                rxFatalError("Invalid state")
            case .initial:
                if let removeKey = self._group.insert(d) {
                    scheduleState = .added(removeKey)
                }
                else {
                    scheduleState = .done
                }
            case .done:
                break
            }
        }
    }

    /// 调度递归执行的操作。
    ///
    /// - parameter state: 状态传递给要执行的操作。
    func schedule(_ state: State) {
        var scheduleState: ScheduleState = .initial

        let d = self._scheduler.schedule(state) { state -> Disposable in
            // best effort
            if self._group.isDisposed {
                return Disposables.create()
            }
            
            let action = self._lock.calculateLocked { () -> Action? in
                switch scheduleState {
                case let .added(removeKey):
                    self._group.remove(for: removeKey)
                case .initial:
                    break
                case .done:
                    break
                }

                scheduleState = .done
                
                return self._action
            }
           
            if let action = action {
                action(state, self)
            }
            
            return Disposables.create()
        }
        
        self._lock.performLocked {
            switch scheduleState {
            case .added:
                rxFatalError("Invalid state")
            case .initial:
                if let removeKey = self._group.insert(d) {
                    scheduleState = .added(removeKey)
                }
                else {
                    scheduleState = .done
                }
            case .done:
                break
            }
        }
    }
    
    func dispose() {
        self._lock.performLocked {
            self._action = nil
        }
        self._group.dispose()
    }
}

/// 立即执行的递归调度器
final class RecursiveImmediateScheduler<State> {
    typealias Action =  (_ state: State, _ recurse: (State) -> Void) -> Void
    
    private var _lock = SpinLock()
    private let _group = CompositeDisposable()
    
    private var _action: Action?
    private let _scheduler: ImmediateSchedulerType
    
    init(action: @escaping Action, scheduler: ImmediateSchedulerType) {
        self._action = action
        self._scheduler = scheduler
    }
    
    // 立即执行
    
    /// 递归执行事件
    ///
    /// - parameter state: State passed to the action to be executed.
    func schedule(_ state: State) {
        var scheduleState: ScheduleState = .initial

        let d = self._scheduler.schedule(state) { state -> Disposable in
            // best effort
            if self._group.isDisposed {
                return Disposables.create()
            }
            
            let action = self._lock.calculateLocked { () -> Action? in
                switch scheduleState {
                case let .added(removeKey):
                    self._group.remove(for: removeKey)
                case .initial:
                    break
                case .done:
                    break
                }

                scheduleState = .done

                return self._action
            }
            
            if let action = action {
                action(state, self.schedule)
            }
            
            return Disposables.create()
        }
        
        self._lock.performLocked {
            switch scheduleState {
            case .added:
                rxFatalError("Invalid state")
            case .initial:
                if let removeKey = self._group.insert(d) {
                    scheduleState = .added(removeKey)
                }
                else {
                    scheduleState = .done
                }
            case .done:
                break
            }
        }
    }
    
    func dispose() {
        self._lock.performLocked {
            self._action = nil
        }
        self._group.dispose()
    }
}
