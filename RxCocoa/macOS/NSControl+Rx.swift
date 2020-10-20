//
//  NSControl+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import Cocoa
import RxSwift

private var rx_value_key: UInt8 = 0
private var rx_control_events_key: UInt8 = 0

extension Reactive where Base: NSControl {

    /// 控件事件的包装器。
    public var controlEvent: ControlEvent<()> {
        MainScheduler.ensureRunningOnMainThread()

        let source = self.lazyInstanceObservable(&rx_control_events_key) { () -> Observable<Void> in
            Observable.create { [weak control = self.base] observer in
                MainScheduler.ensureRunningOnMainThread()
                // 控件不存在直接结束
                guard let control = control else {
                    observer.on(.completed)
                    return Disposables.create()
                }

                // 改了下名字防止产生歧义，这地方将在控件的响应事件里面调用给定的闭包函数
                let disposer = ControlTarget(control: control) { _ in
                    observer.on(.next(()))
                }
                
                return disposer
            }
            .take(until: self.deallocated)
			.share()
        }

        return ControlEvent(events: source)
    }

    /// Creates a `ControlProperty` that is triggered by target/action pattern value updates.
    ///
    /// - parameter getter: Property value getter.
    /// - parameter setter: Property value setter.
    public func controlProperty<T>(
        getter: @escaping (Base) -> T,
        setter: @escaping (Base, T) -> Void
    ) -> ControlProperty<T> {
        MainScheduler.ensureRunningOnMainThread()

        let source = self.base.rx.lazyInstanceObservable(&rx_value_key) { () -> Observable<()> in
                return Observable.create { [weak weakControl = self.base] (observer: AnyObserver<()>) in
                    guard let control = weakControl else {
                        observer.on(.completed)
                        return Disposables.create()
                    }

                    observer.on(.next(()))

                    let observer = ControlTarget(control: control) { _ in
                        if weakControl != nil {
                            observer.on(.next(()))
                        }
                    }

                    return observer
                }
                .take(until: self.deallocated)
                .share(replay: 1, scope: .whileConnected)
            }
            .flatMap { [weak base] _ -> Observable<T> in
                guard let control = base else { return Observable.empty() }
                return Observable.just(getter(control))
            }

        let bindingObserver = Binder(self.base, binding: setter)

        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}


#endif
