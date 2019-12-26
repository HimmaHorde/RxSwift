//
//  Event.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// 表示序列的事件。
///
/// 序列语法:
/// **next\* (error | completed)**
public enum Event<Element> {
    /// 生成下一个元素。
    case next(Element)

    /// 序列错误结束。
    case error(Swift.Error)

    /// 序列正常结束。
    case completed
}

extension Event: CustomDebugStringConvertible {
    /// 对事件的描述。
    public var debugDescription: String {
        switch self {
        case .next(let value):
            return "next(\(value))"
        case .error(let error):
            return "error(\(error))"
        case .completed:
            return "completed"
        }
    }
}

extension Event {
    /// 是否为 `completed` 或者 `error` 事件.
    public var isStopEvent: Bool {
        switch self {
        case .next: return false
        case .error, .completed: return true
        }
    }

    /// 如果是 `next` 事件, 返回元素值 否则返回 nil.
    public var element: Element? {
        if case .next(let value) = self {
            return value
        }
        return nil
    }

    /// 如果是 `error` 事件, 返回 error 否则返回 nil.
    public var error: Swift.Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }

    /// 如果是 `completed` 事件, 返回 `true`.
    public var isCompleted: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}

extension Event {
    /// 遍历转换序列的值. 如果转换过程中发生错误，返回 `.error`。
    /// will be returned as value.
    public func map<Result>(_ transform: (Element) throws -> Result) -> Event<Result> {
        do {
            switch self {
            case let .next(element):
                return .next(try transform(element))
            case let .error(error):
                return .error(error)
            case .completed:
                return .completed
            }
        }
        catch let e {
            return .error(e)
        }
    }
}

/// 可以转换为 `Event<Element>` 的类型的协议.
public protocol EventConvertible {
    /// 事件中元素的类型
    associatedtype Element

    @available(*, deprecated, renamed: "Element")
    typealias ElementType = Element

    /// 此实例的事件表示形式
    var event: Event<Element> { get }
}

extension Event: EventConvertible {
    /// Event representation of this instance
    public var event: Event<Element> {
        return self
    }
}
