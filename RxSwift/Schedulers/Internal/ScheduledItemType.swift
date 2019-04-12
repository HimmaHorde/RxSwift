//
//  ScheduledItemType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 11/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol ScheduledItemType
    : Cancelable
    , InvocableType {
    // 调用
    func invoke()
}
