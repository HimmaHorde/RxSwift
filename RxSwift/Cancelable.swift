//
//  Cancelable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 可释放资源协议，资源释放状态协议
public protocol Cancelable : Disposable {
    /// 资源是否已被释放
    var isDisposed: Bool { get }
}
