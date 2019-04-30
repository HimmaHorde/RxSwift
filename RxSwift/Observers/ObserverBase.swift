//
//  ObserverBase.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 基类,内含抽象方法 onCore
/// 调用 dispose ，或者 completed error 方法后不在接收事件。
class ObserverBase<Element> : Disposable, ObserverType {
    private let _isStopped = AtomicInt(0)

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            if load(self._isStopped) == 0 {
                self.onCore(event)
            }
        case .error, .completed:
            if fetchOr(self._isStopped, 1) == 0 {
                self.onCore(event)
            }
        }
    }

    func onCore(_ event: Event<Element>) {
        rxAbstractMethod()
    }

    func dispose() {
        fetchOr(self._isStopped, 1)
    }
}
