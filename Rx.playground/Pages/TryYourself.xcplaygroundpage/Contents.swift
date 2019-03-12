/*:
 > # IMPORTANT: To use **Rx.playground**:
 1. Open **Rx.xcworkspace**.
 1. Build the **RxSwift-macOS** scheme (**Product** → **Build**).
 1. Open **Rx** playground in the **Project navigator**.
 1. Show the Debug Area (**View** → **Debug Area** → **Show Debug Area**).
 */
import RxSwift
/*:
 # Try Yourself
 
 It's time to play with Rx 🎉
 */
playgroundShouldContinueIndefinitely()

//example("Try yourself") {
//
//}

typealias AAA = (String)->()

class Person {
    var name: String?
    var age: Int?
    var friend: Person?

    init(name:String, age:Int) {
        self.name = name
        self.age = age
    }

    func show(_ other: String){
        print(" + \(other)")
    }
    deinit {
        print("\(name!) dealloc")
    }
}

class KK {
    var name: String?
    weak var ac: AAA?
}
//var ac:AAA?

let k = KK.init()
k.name = "KK"

func test() {
    var p = Person.init(name: "山", age: 19)
    k.ac = p.show
}

test()
print("66666")
//k.ac = nil





// 设置为 nil 之前 person 对象未被释放
//ac = nil






