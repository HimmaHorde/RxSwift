//
//  DispatchQueue+Extensions.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/22/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Dispatch

extension DispatchQueue {
    // key
    private static var token: DispatchSpecificKey<()> = {
        let key = DispatchSpecificKey<()>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()

    // 是否是主队列
    static var isMain: Bool {
        return DispatchQueue.getSpecific(key: token) != nil
    }
}
