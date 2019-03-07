//
//  NopDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 不做任何处理.
///
/// Nop = No Operation
fileprivate struct NopDisposable : Disposable {
 
    fileprivate static let noOp: Disposable = NopDisposable()
    
    fileprivate init() {
        
    }
    
    /// 啥都不做
    public func dispose() {
    }
}

extension Disposables {
    /**
     无操作的资源处理
     */
    static public func create() -> Disposable {
        return NopDisposable.noOp
    }
}
