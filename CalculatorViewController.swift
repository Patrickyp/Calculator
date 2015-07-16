//
//  ViewController.swift
//  Calculator
//
//  Created by Patrick Pan on 5/17/15.
//  Copyright (c) 2015 Patrick Pan. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel! {
        didSet{
            title = "TI-93+ Silver Edition"
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    var brain = CalculatorBrain()
    
    var isFirstDigit = true
    var historyStack = Array<String>()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let GVC = destination as? GraphViewController {
            GVC.brain = brain
        }
        
    }
    
    @IBAction func graphButton() {
        
    }
    //access the display value as double?
    var displayValue: Double? {
        get{
            removeEqual()
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            
        }
        set{
            if(newValue == nil){
                display.text = " "
            } else {
                display.text = "\(newValue!)"
            }
        }
    }
    
    //Takes button as arguement, append button's digit to the display
    @IBAction func appendDigit(sender: UIButton) {
        
        //digit stores the number as string
        let digit = sender.currentTitle!
        //if user typing first digit, replace 0 with digit
        if isFirstDigit {
            display.text = digit
            isFirstDigit = false
            //else append digit to end of number
        } else{
            display.text = display.text! + digit
            
        }
        
    }
    
    
    @IBAction func decimal() {
        //first digit just replace
        if(isFirstDigit){
            display.text = "0." //replace with "0."
            isFirstDigit = false
        }
        //else append if current number doesn't contain "."
        else if(display.text!.rangeOfString(".") == nil){
            display.text = display.text! + "." //append . to end
        }
    }
    
    
    @IBAction func delete() {
        if(!isFirstDigit) && (countElements(display.text!) > 0){
            display.text = dropLast(display.text!)
            if(countElements(display.text!) == 0){
                display.text = "0"
                isFirstDigit = true
            }
        }
    }
    
    @IBAction func cancel() {
        //stack.removeAll(keepCapacity: true)
        brain.clear()
        displayValue = 0
        descriptionLabel.text = "History:"
    }
    
    //add display values to stack
    @IBAction func enter() {
        isFirstDigit = true
        if let result = brain.pushOperand(displayValue!){
            displayValue = result
            descriptionLabel.text = brain.description
        } else {
            displayValue = nil
        }
        //println("Internal stack = \(stack)")
    }
    
    @IBAction func operators(sender: UIButton) {
        if !isFirstDigit{
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                descriptionLabel.text = brain.description
                displayValue = result
            } else {
                descriptionLabel.text = brain.description
                displayValue = nil
            }
        }
        removeEqual()
        display.text = display.text! + "="
    }
    
    //TODO
    @IBAction func plusMinus() {
        if !isFirstDigit {
            if displayValue >= 0{
                display.text = "-" + display.text!
            } else{
                display.text = dropFirst(display.text!)
            }
            return
        } else{ //either 0 or result of computation
            if displayValue == 0 {
                return
            }
            //performOperation{-1*($0)}
        }
        
    }
    //set M value to current value in display
    @IBAction func pushM() {
        if displayValue != nil {
            brain.variableValues["M"] = displayValue
            displayValue = brain.evaluate()
            isFirstDigit = true
        }
    }
    
    //push M into stack
    @IBAction func setM() {
        //enter()
        brain.pushOperand("M")
        descriptionLabel.text = brain.description
        isFirstDigit = true
        
    }
    /****Helper methods****/
    
    //get rid of "=" in display if there
    func removeEqual(){
        if display.text!.hasSuffix("="){
            display.text! = dropLast(display.text!)
        }
    }
    
}

