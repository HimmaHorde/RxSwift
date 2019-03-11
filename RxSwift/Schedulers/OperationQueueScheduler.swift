//
//  OperationQueueScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import class Foundation.Operation
import class Foundation.OperationQueue
import class Foundation.BlockOperation
import Dispatch

/// OperationQueueScheduler 抽象了 NSOperationQueue。
///
/// 它具备 NSOperationQueue 的一些特点，例如，你可以通过设置 maxConcurrentOperationCount，来控制同时执行并发任务的最大数量。
public class OperationQueueScheduler: ImmediateSchedulerType {
    public let operationQueue: OperationQueue
    public let queuePriority: Operation.QueuePriority
    
    /// Constructs new instance of `OperationQueueScheduler` that performs work on `operationQueue`.
    ///
    /// - parameter operationQueue: Operation queue targeted to perform work on.
    /// - parameter queuePriority: Queue priority which will be assigned to new operations.
    public init(operationQueue: OperationQueue, queuePriority: Operation.QueuePriority = .normal) {
        self.operationQueue = operationQueue
        self.queuePriority = queuePriority
    }
    
    /**
    Schedules an action to be executed recursively.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to execute recursively. The last parameter passed to the action is used to trigger recursive scheduling of the action, passing in recursive invocation state.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()

        let operation = BlockOperation {
            if cancel.isDisposed {
                return
            }


            cancel.setDisposable(action(state))
        }

        operation.queuePriority = self.queuePriority

        self.operationQueue.addOperation(operation)
        
        return cancel
    }

}
