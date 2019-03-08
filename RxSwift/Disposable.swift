//
//  Disposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// protocol：可释放资源协议。
public protocol Disposable {
    /// 释放资源。
    func dispose()
}
