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

class person {
    var name: String?
    var age: Int?

    init(name:String, age:Int) {
        self.name = name
        self.age = age
    }

    func show(_ other: String){
        print("\(name) + \(other)")
    }
    deinit {
        print("person dealloc")
    }
}


func test() {
    var p = person.init(name: "山", age: 19)
    var ac:AAA?
    ac = p.show
    ac?("heheda")
}

test()
print("66666")


// 设置为 nil 之前 person 对象未被释放
//ac = nil






