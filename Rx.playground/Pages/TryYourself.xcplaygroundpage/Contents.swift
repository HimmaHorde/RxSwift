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

//let aaa
//    = Observable<Int>
//        .timer(2, period: 1, scheduler: MainScheduler.instance)
//        .map { "当前索引 = \(Date.init(timeIntervalSince1970: 0))" }
////        .publish()
////        .refCount()
////aaa.connect()
//        .share(replay: 2, scope: .whileConnected)
//
//let ob1:AnyObserver<String> = AnyObserver.init { (e) in
//    switch e {
//    case .next(let aaa):
//        print("11\(aaa)");
//    default:
//        break
//    }
//}
//
//let ob3:AnyObserver<String> = AnyObserver.init { (e) in
//    switch e {
//    case .next(let aaa):
//        print("33\(aaa)");
//    default:
//        break
//    }
//}
//
//let bag = aaa.bind(to: ob1)
//
//delay(5) {
//    bag.dispose()
//}
//
//delay(8) {
//    aaa.bind(to: ob3)
//}
let xs:Observable<TimeInterval> = Observable.create({ (obsver) -> Disposable in
    print("重新执行了")
    obsver.onNext(Date().timeIntervalSince1970)
    delay(2, closure: {
        obsver.onCompleted()
    })
    delay(4, closure: {
        obsver.onNext(Date().timeIntervalSince1970)
    })
    delay(6, closure: {
        obsver.onNext(Date().timeIntervalSince1970)
    })
    delay(8, closure: {
        obsver.onCompleted()
    })
         return Disposables.create()
    })
//    .debug()
    .share(replay: 0, scope: .forever)

let a = xs.subscribe(onNext: { print("1 next \($0)") }, onCompleted: { print("1 completed\n") })

delay(3) {
    let b = xs.subscribe(onNext: { print("2 next \($0)") }, onCompleted: { print("2 completed\n") })
    let c = xs.subscribe(onNext: { print("3 next \($0)") }, onCompleted: { print("3 completed\n") })
}











