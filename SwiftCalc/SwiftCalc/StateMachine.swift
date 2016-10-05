import Foundation

func eval(num1: Double, num2: Double, op: String) -> Double {
    switch op {
    case "+":
        return num1 + num2
    case "-":
        return num1 - num2
    case "*":
        return num1 * num2
    case "/":
        return num1 / num2
    default:
        assert(false, "unknown op \(op)")
    }
}

class StateContext {
    
    var currentState: State!
    var first: State!
    var second: State!
    var op: State!
    var result: State!
    
    var num1: Double = 0.0
    var num2: Double = 0.0
    var pendingOp: String = "+"
    
    init() {
        first = FirstState(context: self)
        second = SecondState(context: self)
        op = OpState(context: self)
        result = ResultState(context: self)
        currentState = first
    }
    
    func display() -> String? {
        return self.currentState.display()
    }
    
    func input(_ s: String) {
        switch s {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            let event = NumberEvent(input: s, context: self)
            self.currentState.handle(event)
            break
        case "+", "-", "*", "/":
            let event = OperatorEvent(input: s, context: self)
            self.currentState.handle(event)
            break
        case "C":
            let event = ClearEvent(input: s, context: self)
            self.currentState.handle(event)
        case ".":
            let event = PointEvent(input: s, context: self)
            self.currentState.handle(event)
        case "=":
            let event = EqualEvent(input: s, context: self)
            self.currentState.handle(event)
        case "+/-":
            let event = FlipSignEvent(input: s, context: self)
            self.currentState.handle(event)
        default:
            return
        }
    }
}

class State {
    
    let context: StateContext
    var tempOperand: String = "0"
    
    init(context: StateContext) {
        self.context = context
    }

    // handle an event
    // modify state and start transition if necessary
    func handle(_ event: OperatorEvent) {
        self.context.currentState = self.context.op
        self.context.pendingOp = event.input
    }
    func handle(_ event: NumberEvent) {
        tempOperand = event.process(oldNum: tempOperand)
    }
    func handle(_ event: EqualEvent) {}
    func display() -> String? {
        return tempOperand
    }
}

class Event {

    let context: StateContext
    let input: String
    
    init(input: String, context: StateContext) {
        self.context = context
        self.input = input
        print("Event \(input)")
    }
}

class FirstState: State {
    override func handle(_ event: OperatorEvent) {
        super.handle(event)
        self.context.num1 = Double(self.tempOperand)!
        self.context.currentState.tempOperand = tempOperand
    }
}

class SecondState: State {
    func commonHandle() {
        let d = Double(self.tempOperand)!
        let v = eval(num1: self.context.num1, num2: d, op: self.context.pendingOp)
        self.context.num1 = v
        self.tempOperand = "0"
    }
    
    override func handle(_ event: OperatorEvent) {
        commonHandle()
        super.handle(event)
        self.context.currentState.tempOperand = self.context.num1.prettyOutput
    }
    
    override func handle(_ event: EqualEvent) {
        self.context.currentState = self.context.result
        commonHandle()
        self.context.currentState.tempOperand = self.context.num1.prettyOutput
    }
}
class OpState: State {
    override func handle(_ event: NumberEvent) {
        self.context.currentState = self.context.second
        self.context.second.handle(event)
    }
}

class ResultState: State {
    override func handle(_ event: OperatorEvent) {
        super.handle(event)
        self.context.currentState.tempOperand = self.tempOperand
    }
    
    override func handle(_ event: NumberEvent) {
        self.context.currentState = self.context.first
        self.context.currentState.tempOperand = "0"
        self.context.currentState.handle(event)
    }
}


class OperatorEvent: Event {
    let op: String
    override init(input: String, context: StateContext) {
        self.op = input
        super.init(input: input, context: context)
    }
}

class NumberEvent: Event {
    func process(oldNum: String) -> String {
        if oldNum.characters.count >= 7 {
            return oldNum
        }
        if oldNum == "0" {
            return self.input
        } else {
            return oldNum + self.input
        }
    }
}

class ClearEvent: NumberEvent {
    override func process(oldNum: String) -> String {
        return "0"
    }
}

class PointEvent: NumberEvent {
    override func process(oldNum: String) -> String {
        if oldNum.contains(".") || oldNum.characters.count >= 7 {
            return oldNum
        } else {
            return oldNum + "."
        }
    }
}

class FlipSignEvent: NumberEvent {
    override func process(oldNum: String) -> String {
        if oldNum.characters.count >= 7 {
            return oldNum
        }
        if oldNum[oldNum.startIndex] == "-" {
            return oldNum.substring(from: oldNum.index(oldNum.startIndex, offsetBy: 1))
        } else {
            return "-" + oldNum
        }
    }
}

class EqualEvent: Event {}
