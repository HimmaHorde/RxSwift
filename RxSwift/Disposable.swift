//
//  Disposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// protocol：可被清除的资源。
public protocol Disposable {
    /// 清除资源。
    func dispose()
}
