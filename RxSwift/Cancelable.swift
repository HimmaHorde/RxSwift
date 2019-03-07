//
//  Cancelable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 表示带有状态跟踪的可处理资源。
public protocol Cancelable : Disposable {
    /// 是已处理资源
    var isDisposed: Bool { get }
}
