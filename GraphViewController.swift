//
//  GraphViewController.swift
//  Calculator
//
//  Created by Patrick Pan on 6/8/15.
//  Copyright (c) 2015 Patrick Pan. All rights reserved.
//

import UIKit

protocol GraphViewControllerDelegate {
    func equationToString(sender: GraphViewController) -> String?
}

class GraphViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    
    
    
    //brain is set during prepareForSegue by CalculatorViewController to its brain
    var brain: CalculatorBrain = CalculatorBrain()
    
    var dataSource: GraphViewControllerDelegate?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "Show Statistic":
                if let tvc = segue.destinationViewController as? StatisticViewController{
                    if let poc = tvc.popoverPresentationController {
                        poc.delegate = self
                    }
                    tvc.text = GraphViewOutlet.returnStat()
                }
                
                default: break
            }
        }
    }
    

    @IBAction func ResetDefault() {
        if GraphViewOutlet != nil{
            GraphViewOutlet.resetGraph()
        }
    }
    @IBOutlet weak var GraphViewOutlet: GraphView! {
        didSet{
            
            //retrieve GraphView's saved zoom and origin setting
            GraphViewOutlet.fetchDefaults()
            
            //set both dataSource to passed brain object
            GraphViewOutlet.dataSource = brain
            dataSource = brain
            
            //Set title
            if let titleEquation = dataSource?.equationToString(self) {
                if titleEquation != ""{
                    title = "y = \(titleEquation)"
                }
            }
            
            //add gestures
            GraphViewOutlet.addGestureRecognizer(UIPinchGestureRecognizer(target: GraphViewOutlet, action: "Pinch:"))
            GraphViewOutlet.addGestureRecognizer(UITapGestureRecognizer(target: GraphViewOutlet, action: "Tap:"))
            GraphViewOutlet.addGestureRecognizer(UIPanGestureRecognizer(target: GraphViewOutlet, action: "Pan:"))
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }


}
