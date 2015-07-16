//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Patrick Pan on 5/22/15.
//  Copyright (c) 2015 Patrick Pan. All rights reserved.
//

import Foundation

class CalculatorBrain: GraphViewDelegate, GraphViewControllerDelegate{
    
    //constructor, fill knowOps dictionary with possible "Op"
    init(){
        knownOps["*"] = Op.BinaryOperation("*"){$0 * $1}
        knownOps["-"] = Op.BinaryOperation("-"){$1 - $0}
        knownOps["+"] = Op.BinaryOperation("+"){$0 + $1}
        knownOps["/"] = Op.BinaryOperation("/"){$1 / $0}
        knownOps["√"] = Op.UnaryOperation("√"){sqrt($0)}
        knownOps["sin"] = Op.UnaryOperation("sin"){sin($0)}
        knownOps["cos"] = Op.UnaryOperation("cos"){cos($0)}
    }
    
    
    //return stack in human readable format
    var description: String {
        get {
            println("\(opStack)")
            return sToString(opStack, firstOnly: false) //return result of function
        }
    }
    
    //store the values of variable operands e.g. x=4
    var variableValues = [String: Double]()
    
    //an array holding "Op" enums as a stack, main storage
    private var opStack = [Op]()
    
    //dictionary storing possible uary/binary operations
    private var knownOps = [String: Op]()
    
    //whether to use dictionary or
    private var delegateValue: Double? = nil
    
    //recurse through opStack, print in readable form 
    private func stackToString(ops: [Op]) -> (result: String?, remainingOps: [Op]){
        if(!ops.isEmpty){
            var remainingOps = ops //remainingOps = opStack copy
            let op = remainingOps.removeLast() //op = op enum
            
            switch op {
            case .Operand(let operand): //operand = double value
                return ("\(operand)", remainingOps)
            case .VariableOperand(let variableName):
                return (variableName, remainingOps)
                
            case .UnaryOperation(let symbol,_):
                let operandEvaluation = stackToString(remainingOps)
                if let operand = operandEvaluation.result {
                    //remove extra ()
                    if operand[operand.startIndex] == "(" {
                        return ("\(symbol)\(operand)", operandEvaluation.remainingOps)
                    }//no extra ()
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                } else{
                    return ("\(symbol)(?)", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol,_):
                let op1Evaluation = stackToString(remainingOps)
                var operand1 = op1Evaluation.result
                let op2Evaluation = stackToString(op1Evaluation.remainingOps)
                var operand2 = op2Evaluation.result
                if(operand1 == nil){
                    operand1 = "?"
                }
                if(operand2 == nil){
                    operand2 = "?"
                }
                return("(\(operand2!) \(symbol) \(operand1!))", op2Evaluation.remainingOps)
            }
        }
        return (nil, ops)
    }
    
    //this will be called first
    private func sToString(remainStack: [Op], firstOnly: Bool) -> String {
        if(!remainStack.isEmpty) {
            var currentStack = remainStack
            let (result,remainingOps) = stackToString(currentStack)
            var stringResult = result!
            //remove extra outer () if exists
            if stringResult[stringResult.startIndex] == "(" {
                stringResult = dropFirst(stringResult)
                stringResult = dropLast(stringResult)
            }
            if(remainingOps.count == 0 || firstOnly){
                return stringResult
            } else {
                return "\(sToString(remainingOps, firstOnly: false)), \(stringResult) "
            }
            
        }
        return "" //triggered when opStack is empty
    }
    
    //enum holding possible operand/operation types
    private enum Op: Printable{
        case Operand(Double)  //a number
        case VariableOperand(String) //i.e. x
        case UnaryOperation(String, Double -> Double) //the symbol(String) and function
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .VariableOperand(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    var program: AnyObject { //always a Property List (a data structure as an AnyObject)
        get {
            //return a ArrayList hold the description of ever Op in opStack
            return opStack.map {$0.description}
        }
        set {
            //If passed array is a Array<String>
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if(!ops.isEmpty){
            var remainingOps = ops //remainingOps = opStack copy
            let op = remainingOps.removeLast() //op = op enum
            switch op {
            case .Operand(let operand): //operand = double value
                return (operand, remainingOps)
            case .VariableOperand(let symbol):
                //check if someone is delegating
                if let value = delegateValue {
                    return (value, remainingOps)
                }
                //if variable exists in variableValues
                if let value = variableValues[symbol]{
                    return (value, remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps) //operandEvaluation = tuple
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_,let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                
                }
            }
        }
        return (nil, ops)
    }
    
    //this will be called first
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        //println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    //push an operand into stack
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand)) //create a new Operand enum
        return evaluate()
    }
    //push a variable operand into stack
    func pushOperand(symbol: String) -> Double?{
        opStack.append(Op.VariableOperand(symbol))
        return evaluate()
    }
    
    
    //push a operation into stack, symbol is +/-/* etc...
    func performOperation(symbol: String) -> Double?{
        if let operation = knownOps[symbol] { //returns an optional(Op?)
            opStack.append(operation)
        }
        //println("\(getD())    stack contents = \(opStack)")
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll(keepCapacity: true)
        variableValues.removeAll(keepCapacity: true)
        
    }
    //return the y value calculated using given x as value of M
    func graphValue(sender: GraphView, mValue: Double) -> Double? {
        delegateValue = Double(mValue)
        var result = evaluate()
        delegateValue = nil //set delgateValue back to nil
        return result
    }
    //return the top equation of stack in string form
    func equationToString(sender: GraphViewController) -> String? {
        return sToString(opStack, firstOnly: true)
    }

    
}