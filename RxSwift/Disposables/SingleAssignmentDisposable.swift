//
//  SingleAssignmentDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/**
表示一个 disposable 实例，只允许对其底层的 disposable 资源处理一次，如果其底层 disposable 资源已存在，再次设置会报错。

 - 如果其底层 disposable 资源已存在，再次设置会报错。
 - 只允许对其底层的 disposable 资源处理一次

 大白话：

 源 disposable 对象外面包了一层，只可以执行一次有效的dispose()方法。
*/
public final class SingleAssignmentDisposable : DisposeBase, Cancelable {

    private enum DisposeState: Int32 {
        case disposed = 1
        case disposableSet = 2
    }

    // state
    private let _state = AtomicInt(0)
    private var _disposable = nil as Disposable?

    /// - returns: 表示是否已处理
    public var isDisposed: Bool {
        return isFlagSet(self._state, DisposeState.disposed.rawValue)
    }

    /// Initializes a new instance of the `SingleAssignmentDisposable`.
    public override init() {
        super.init()
    }

    /// 设置底层的 Disposable 对象
    ///
    /// **重复设置报错**
    public func setDisposable(_ disposable: Disposable) {
        self._disposable = disposable

        let previousState = fetchOr(self._state, DisposeState.disposableSet.rawValue)

        // 重复设置
        if (previousState & DisposeState.disposableSet.rawValue) != 0 {
            rxFatalError("oldState.disposable != nil")
        }

        // 未设置之前已调用 dispose 直接处理
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            disposable.dispose()
            self._disposable = nil
        }
    }

    /// 调用底层的 Disposable 资源处理，并释放底层 Disposable 对象。
    public func dispose() {
        let previousState = fetchOr(self._state, DisposeState.disposed.rawValue)

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }

        if (previousState & DisposeState.disposableSet.rawValue) != 0 {
            guard let disposable = self._disposable else {
                rxFatalError("Disposable not set")
            }
            disposable.dispose()
            self._disposable = nil
        }
    }

}
