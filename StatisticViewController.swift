//
//  StatisticViewController.swift
//  POPOVER WINDOW
//  Calculator
//
//  Created by Patrick Pan on 6/12/15.
//  Copyright (c) 2015 Patrick Pan. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController {

    
    
    @IBOutlet weak var StatisticView: UITextView!{
        didSet {
            StatisticView.text = text
        }
    }
    
    var text: String = ""{
        didSet{
            StatisticView?.text = text
        }
    }
    
    //make popover size match its contents
    override var preferredContentSize: CGSize {
        get{
            if StatisticView != nil && presentingViewController != nil {
                
                let textSize = StatisticView.sizeThatFits(presentingViewController!.view.bounds.size)
                //Height is approximate height of button, will change later
                return CGSize(width: textSize.width, height: textSize.height)
            } else {
                return super.preferredContentSize
            }
        }
        set{
            super.preferredContentSize = newValue
        }
    }
}
