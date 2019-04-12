//
//  CurrentThreadSchedulerTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest

class CurrentThreadSchedulerTest : RxTest {

}

extension CurrentThreadSchedulerTest {
    func testCurrentThreadScheduler_scheduleRequired() {

        /*
            isScheduleRequired 默认为 true
            isScheduleRequired 有一个在任务在执行则值为 false
            isScheduleRequired 所有任务完成 true
         */

        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var executed = false
        _ = CurrentThreadScheduler.instance.schedule(()) { _ in
            executed = true
            XCTAssertTrue(!CurrentThreadScheduler.isScheduleRequired)
            return Disposables.create()
        }

        XCTAssertTrue(executed)
    }

    // 基本情况测试
    func testCurrentThreadScheduler_basicScenario() {

        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { _ in
            messages.append(1)
            _ = CurrentThreadScheduler.instance.schedule(()) { _ in
                messages.append(3)
                _ = CurrentThreadScheduler.instance.schedule(()) {
                    messages.append(5)
                    return Disposables.create()
                }
                messages.append(4)
                return Disposables.create()
            }
            messages.append(2)
            return Disposables.create()
        }

        XCTAssertEqual(messages, [1, 2, 3, 4, 5])
    }

    func testCurrentThreadScheduler_disposing1() {

        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { _ in
            messages.append(1)
            let disposable = CurrentThreadScheduler.instance.schedule(()) { _ in
                messages.append(3)
                let disposable = CurrentThreadScheduler.instance.schedule(()) {
                    messages.append(5)
                    return Disposables.create()
                }
                disposable.dispose()
                messages.append(4)
                return disposable
            }
            messages.append(2)
            return disposable
        }

        XCTAssertEqual(messages, [1, 2, 3, 4])
    }

    func testCurrentThreadScheduler_disposing2() {

        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { _ in
            messages.append(1)
            let disposable = CurrentThreadScheduler.instance.schedule(()) { _ in
                messages.append(3)
                let disposable = CurrentThreadScheduler.instance.schedule(()) {
                    messages.append(5)
                    return Disposables.create()
                }
                messages.append(4)
                return disposable
            }
            disposable.dispose()
            messages.append(2)
            return disposable
        }

        XCTAssertEqual(messages, [1, 2])
    }
}
