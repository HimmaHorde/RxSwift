//
//  DispatchQueueConfiguration.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/23/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import struct Foundation.TimeInterval



/// 队列配置(包含DispatchQueue队列对象，和时间)
struct DispatchQueueConfiguration {
    let queue: DispatchQueue
    let leeway: DispatchTimeInterval
}


/// 时间单位转换，秒 转 DispatchTimeInterval
///
/// - Parameter interval:时间
/// - Returns:转换后的时间
private func dispatchInterval(_ interval: Foundation.TimeInterval) -> DispatchTimeInterval {
    precondition(interval >= 0.0)
    // TODO: Replace 1000 with something that actually works 
    // NSEC_PER_MSEC returns 1000000
    // 毫秒 -> 转化为 DispatchTimeInterval
    return DispatchTimeInterval.milliseconds(Int(interval * 1000.0))
}

extension DispatchQueueConfiguration {
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()

        self.queue.async {
            if cancel.isDisposed {
                return
            }


            cancel.setDisposable(action(state))
        }

        return cancel
    }

    func scheduleRelative<StateType>(_ state: StateType, dueTime: Foundation.TimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        let deadline = DispatchTime.now() + dispatchInterval(dueTime)

        let compositeDisposable = CompositeDisposable()

        let timer = DispatchSource.makeTimerSource(queue: self.queue)
        timer.schedule(deadline: deadline, leeway: self.leeway)

        // TODO:
        // This looks horrible, and yes, it is.
        // It looks like Apple has made a conceputal change here, and I'm unsure why.
        // Need more info on this.
        // It looks like just setting timer to fire and not holding a reference to it
        // until deadline causes timer cancellation.
        var timerReference: DispatchSourceTimer? = timer
        let cancelTimer = Disposables.create {
            timerReference?.cancel()
            timerReference = nil
        }

        timer.setEventHandler(handler: {
            if compositeDisposable.isDisposed {
                return
            }
            _ = compositeDisposable.insert(action(state))
            cancelTimer.dispose()
        })
        timer.resume()

        _ = compositeDisposable.insert(cancelTimer)

        return compositeDisposable
    }

    func schedulePeriodic<StateType>(_ state: StateType, startAfter: TimeInterval, period: TimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        let initial = DispatchTime.now() + dispatchInterval(startAfter)

        var timerState = state

        let timer = DispatchSource.makeTimerSource(queue: self.queue)
        timer.schedule(deadline: initial, repeating: dispatchInterval(period), leeway: self.leeway)
        
        // TODO:
        // This looks horrible, and yes, it is.
        // It looks like Apple has made a conceputal change here, and I'm unsure why.
        // Need more info on this.
        // It looks like just setting timer to fire and not holding a reference to it
        // until deadline causes timer cancellation.
        var timerReference: DispatchSourceTimer? = timer
        let cancelTimer = Disposables.create {
            timerReference?.cancel()
            timerReference = nil
        }

        timer.setEventHandler(handler: {
            if cancelTimer.isDisposed {
                return
            }
            timerState = action(timerState)
        })
        timer.resume()
        
        return cancelTimer
    }
}
