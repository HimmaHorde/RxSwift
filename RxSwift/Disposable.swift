//
//  Disposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// protocol：可处理协议。
public protocol Disposable {
    /// 处理方法(释放资源，取消任务。。。)。
    func dispose()
}
