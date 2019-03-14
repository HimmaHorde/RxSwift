/*:
 > # IMPORTANT: To use **Rx.playground**:
 1. Open **Rx.xcworkspace**.
 1. Build the **RxSwift-macOS** scheme (**Product** → **Build**).
 1. Open **Rx** playground in the **Project navigator**.
 1. Show the Debug Area (**View** → **Debug Area** → **Show Debug Area**).
 */
import RxSwift
import RxCocoa
/*:
 # Try Yourself
 
 It's time to play with Rx 🎉
 */
playgroundShouldContinueIndefinitely()

// shareReplay

//let aaa: Observable<String> = Observable.create { (obsver) -> Disposable in
//    delay(0, closure: {
//        obsver.onNext("hello")
//    })
//    print("aaaa")
//    return Disposables.create()
//}.share()

let aaa: Observable<String>
    = Observable<Int>
        .timer(2, period: 1, scheduler: MainScheduler.instance)
        .map { "当前索引 = \($0)" }
        .share(replay: 2, scope: .whileConnected)

let ob1:AnyObserver<String> = AnyObserver.init { (e) in
    switch e {
    case .next(let aaa):
        print("11\(aaa)");
    default:
        break
    }
}

let ob2:AnyObserver<String> = AnyObserver.init { (e) in
    switch e {
    case .next(let aaa):
        print("22\(aaa)");
    default:
        break
    }
}

let ob3:AnyObserver<String> = AnyObserver.init { (e) in
    switch e {
    case .next(let aaa):
        print("33\(aaa)");
    default:
        break
    }
}

aaa.bind(to: ob1)

delay(5) {
    aaa.bind(to: ob2)
}

delay(8) {
    aaa.bind(to: ob3)
}












