//
//  SerialDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 表示一个可使用资源，其底层 Disposable 对象可以赋值，赋值时之前的 Disposable 对象触发 dispose()。
public final class SerialDisposable : DisposeBase, Cancelable {
    private var lock = SpinLock()
    
    // state
    private var current = nil as Disposable?
    private var disposed = false
    
    /// - returns: Was resource disposed.
    public var isDisposed: Bool {
        self.disposed
    }
    
    /// Initializes a new instance of the `SerialDisposable`.
    override public init() {
        super.init()
    }
    
    /**
    Gets or sets the underlying disposable.
    
    Assigning this property disposes the previous disposable object.
    
    If the `SerialDisposable` has already been disposed, assignment to this property causes immediate disposal of the given disposable object.
    */
    public var disposable: Disposable {
        get {
            self.lock.performLocked {
                self.current ?? Disposables.create()
            }
        }
        set (newDisposable) {
            let disposable: Disposable? = self.lock.performLocked {
                if self.isDisposed {
                    return newDisposable
                }
                else {
                    let toDispose = self.current
                    self.current = newDisposable
                    return toDispose
                }
            }
            
            if let disposable = disposable {
                disposable.dispose()
            }
        }
    }
    
    /// 处理底层Disposable，并将之后赋值的Disposable对象直接处理.
    public func dispose() {
        self._dispose()?.dispose()
    }

    private func _dispose() -> Disposable? {
        self.lock.performLocked {
            guard !self.isDisposed else { return nil }

            self.disposed = true
            let current = self.current
            self.current = nil
            return current
        }
    }
}
