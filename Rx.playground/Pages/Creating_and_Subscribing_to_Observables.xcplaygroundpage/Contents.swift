/*:
 > # IMPORTANT: To use **Rx.playground**:
 1. Open **Rx.xcworkspace**.
 1. Build the **RxSwift-macOS** scheme (**Product** → **Build**).
 1. Open **Rx** playground in the **Project navigator**.
 1. Show the Debug Area (**View** → **Debug Area** → **Show Debug Area**).
 ----
 [Previous](@previous) - [Table of Contents](Table_of_Contents)
 */
import RxSwift
/*:
 # Creating and Subscribing to `Observable`s
 There are several ways to create and subscribe to `Observable` sequences.
 ## never
 Creates a sequence that never terminates and never emits any events. [More info](http://reactivex.io/documentation/operators/empty-never-throw.html)
 */
example("never") {
    let disposeBag = DisposeBag()
    let neverSequence = Observable<String>.never()
    
    let neverSequenceSubscription = neverSequence
        .subscribe { _ in
            print("This will never be printed")
    }
    
    neverSequenceSubscription.disposed(by: disposeBag)
}
/*:
 ----
 ## empty
 创建一个只发出 Completed 事件的 `Observable` 序列。 [More info](http://reactivex.io/documentation/operators/empty-never-throw.html)
 */
example("empty") {
    let disposeBag = DisposeBag()
    
    Observable<Int>.empty()
        .subscribe { event in
            print(event)
        }
        .disposed(by: disposeBag)
}
/*:
 > This example also introduces chaining together creating and subscribing to an `Observable` sequence.
 ----
 ## just
 该方法通过传入一个默认值来初始化 `Observable` 序列。 [More info](http://reactivex.io/documentation/operators/just.html)
 */
example("just") {
    let disposeBag = DisposeBag()
    
    Observable.just("🔴")
        .subscribe { event in
            print(event)
        }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## of
 创建固定元素的 `Observable`.
 */
example("of") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐶", "🐱", "🐭", "🐹")
        .subscribe(onNext: { element in
            print(element)
        })
        .disposed(by: disposeBag)
}
/*:
 > This example also introduces using the `subscribe(onNext:)` convenience method. Unlike `subscribe(_:)`, which subscribes an _event_ handler for all event types (Next, Error, and Completed), `subscribe(onNext:)` subscribes an _element_ handler that will ignore Error and Completed events and only produce Next event elements. There are also `subscribe(onError:)` and `subscribe(onCompleted:)` convenience methods, should you only want to subscribe to those event types. And there is a `subscribe(onNext:onError:onCompleted:onDisposed:)` method, which allows you to react to one or more event types and when the subscription is terminated for any reason, or disposed, in a single call:
 ```
 someObservable.subscribe(
     onNext: { print("Element:", $0) },
     onError: { print("Error:", $0) },
     onCompleted: { print("Completed") },
     onDisposed: { print("Disposed") }
 )
```
 ----
 ## from
 从一个数组地点或者set 里面获取元素
 */
example("from") {
    let disposeBag = DisposeBag()
    
    let observable = Observable.from(["🐶": "11", "🐱": "22", "🐭": "33", "🐹": "44"])

    print(type(of: observable))

    observable
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 > This example also demonstrates using the default argument name `$0` instead of explicitly naming the argument.
----
 ## create
 Creates a custom `Observable` sequence. [More info](http://reactivex.io/documentation/operators/create.html)
*/
example("create") {
    let disposeBag = DisposeBag()
    
    let myJust = { (element: String) -> Observable<String> in
        return Observable.create { observer in
            observer.on(.next(element))
            return Disposables.create()
        }
    }

    myJust("🔴")
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## range
 Creates an `Observable` sequence that emits a range of sequential integers and then terminates. [More info](http://reactivex.io/documentation/operators/range.html)
 */
example("range") {
    let disposeBag = DisposeBag()
    
    Observable.range(start: 1, count: 10)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## repeatElement
 Creates an `Observable` sequence that emits the given element indefinitely. [More info](http://reactivex.io/documentation/operators/repeat.html)
 */
example("repeatElement") {
    let disposeBag = DisposeBag()
    
    Observable.repeatElement("🔴")
        .take(3)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 > This example also introduces using the `take` operator to return a specified number of elements from the start of a sequence.
 ----
 ## generate
 该方法创建一个只有当提供的所有的判断条件都为 true 的时候，才会给出动作的 Observable 序列。.
 */
example("generate") {
    let disposeBag = DisposeBag()
    
    Observable.generate(
            initialState: 0,
            condition: { $0 < 13 },
            iterate: { $0 + 1 }
        )
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 ----
 ## deferred
 Creates a new `Observable` sequence for each subscriber. [More info](http://reactivex.io/documentation/operators/defer.html)
 */
example("deferred") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let deferredSequence = Observable<String>.deferred {
        print("Creating \(count)")
        count += 1
        
        return Observable.create { observer in
            print("Emitting...")
            observer.onNext("🐶")
            observer.onNext("🐱")
            observer.onNext("🐵")
            return Disposables.create()
        }
    }
    
    deferredSequence
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    deferredSequence
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

/*:
 ----
 ## interval
 这个方法创建的 Observable 序列每隔一段设定的时间，会发出一个索引数的元素。而且它会一直发送下去。
 */
example("interval") {
    let disposeBag = DisposeBag()
    let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)

    observable.subscribe { event in
                print(event)
    }
}

/*:
 ----
 ## error
 Creates an `Observable` sequence that emits no items and immediately terminates with an error.
 */
example("error") {
    let disposeBag = DisposeBag()
        
    Observable<Int>.error(TestError.test)
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## doOn
 Invokes a side-effect action for each emitted event and returns (passes through) the original event. [More info](http://reactivex.io/documentation/operators/do.html)
 */
example("doOn") {
    let disposeBag = DisposeBag()
    
    Observable.of("🍎", "🍐", "🍊", "🍋")
        .do(onNext: { print("Intercepted:", $0) }, onError: { print("Intercepted error:", $0) }, onCompleted: { print("Completed")  })
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
//: > There are also `doOnNext(_:)`, `doOnError(_:)`, and `doOnCompleted(_:)` convenience methods to intercept those specific events, and `doOn(onNext:onError:onCompleted:)` to intercept one or more events in a single call.

//: [Next](@next) - [Table of Contents](Table_of_Contents)
