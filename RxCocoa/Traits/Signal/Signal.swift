//
//  Signal.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 9/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/**
 表示具有以下属性的可观察特征序列:
 
 - 不会失败
 - 主线程驱动 `MainScheduler.instance`
 - `share(scope: .whileConnected)` sharing strategy

 Additional explanation:
 - 所有观察者共享序列计算资源
 - 不会为新的订阅者重播元素
 - 元素的计算是参照观察者的数量来计算的
 - 如果没有订阅者，它将释放序列计算资源

 In case trait that models state propagation is required, please check `Driver`.

 `Signal<Element>` can be considered a builder pattern for observable sequences that model imperative events part of the application.
 
 To find out more about units and how to use them, please visit `Documentation/Traits.md`.
 */
public typealias Signal<Element> = SharedSequence<SignalSharingStrategy, Element>

public struct SignalSharingStrategy: SharingStrategyProtocol {
    public static var scheduler: SchedulerType { SharingScheduler.make() }
    
    public static func share<Element>(_ source: Observable<Element>) -> Observable<Element> {
        source.share(scope: .whileConnected)
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == SignalSharingStrategy {
    /// Adds `asPublisher` to `SharingSequence` with `PublishSharingStrategy`.
    public func asSignal() -> Signal<Element> {
        self.asSharedSequence()
    }
}
