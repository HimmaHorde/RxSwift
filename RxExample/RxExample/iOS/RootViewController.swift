//
//  RootViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RootViewController : UITableViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        // force load
//        _ = GitHubSearchRepositoriesAPI.sharedAPI
//        _ = DefaultWikipediaAPI.sharedAPI
//        _ = DefaultImageService.sharedImageService
//        _ = DefaultWireframe.shared
//        _ = MainScheduler.instance
//        _ = Dependencies.sharedDependencies.reachabilityService
//
//        let geoService = GeolocationService.instance
//        geoService.authorized.drive(onNext: { _ in
//
//        }).dispose()
//        geoService.location.drive(onNext: { _ in
//
//        }).dispose()

        let myJust = { (element: String) -> Observable<String> in
            return Observable.create { observer in
                observer.on(.next(element))
                observer.on(.completed)
                return Disposables.create()
            }
        }

        myJust("🔴")
            .subscribe { print($0) }
    }
}
