//
//  GraphView.swift
//  Calculator
//
//  Created by Patrick Pan on 6/8/15.
//  Copyright (c) 2015 Patrick Pan. All rights reserved.
//

import UIKit

protocol GraphViewDelegate: class {
    func graphValue(sender: GraphView, mValue: Double) -> Double?
}

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 100{
        didSet{
            setNeedsDisplay()
        }
    }
    
    //save zoom/origin setting between launch of apps
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var defaultArray:[String : CGFloat] {
        get {
            return defaults.objectForKey("savedSettings") as? [String : CGFloat] ?? ["scale":50, "dX":0, "dY":0]
        }
        set{
            defaults.setObject(newValue, forKey: "savedSettings")
        }
    }
    //if origin is moved from center, tracks distance to new origin
    var displacementX: CGFloat = 0
    var displacementY: CGFloat = 0
    
    //will be set after drawRect is called
    var rectWidth: CGFloat = 0
    var rectHeight: CGFloat = 0
    
    func saveDefaults(){
        let tempDic = ["scale": scale, "dX":displacementX, "dY":displacementY]
        defaultArray = tempDic
    }
    
    func fetchDefaults(){
        let tempDic = defaultArray
        scale = tempDic["scale"]!
        displacementX = tempDic["dX"]!
        displacementY = tempDic["dY"]!
    }
    //return current origin coordinates
    var centerX: CGFloat {
        get{
            return convertPoint(center, fromView: superview).x + displacementX
        }
    }
    
    var centerY: CGFloat {
        get{
            return convertPoint(center, fromView: superview).y + displacementY
        }
    }
    
    weak var dataSource: GraphViewDelegate?
    

    func Pinch(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            println("\(scale)")
            gesture.scale = 1
        } else {
            saveDefaults()
        }
    }
    
    func resetGraph() {
        displacementX = 0
        displacementY = 0
        scale = 50
        saveDefaults()
    }
    
    //set origin to location of tap
    func Tap(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            resetDisplacement()
            let touchLocation = gesture.locationInView(self)
            displacementX = touchLocation.x - centerX
            displacementY = touchLocation.y - centerY
            setNeedsDisplay()
            println("\(touchLocation.x) \(touchLocation.y)")
            saveDefaults()
            
        }
    }
    
    private func resetDisplacement(){
        displacementX = 0
        displacementY = 0
    }
    
    //Move origin in conjunction with pan
    func Pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state{
        case .Changed:
            let translation = gesture.translationInView(self)
            //println("x=\(translation.x) , y=\(translation.y)")

            displacementX += translation.x/5
            displacementY += translation.y/5
            setNeedsDisplay()
        default:
            saveDefaults()
        }
    }
    
    func returnStat() -> String {
        let minX: Double = (0-Double(centerX))/Double(scale)
        let maxX: Double = (Double(rectWidth)-Double(centerX))/Double(scale)
        let maxY: Double = -(0-Double(centerY))/Double(scale)
        let minY: Double = -(Double(rectHeight)-Double(centerY))/Double(scale)
        
        return "Min X value = \(minX)\nMax X value = \(maxX)\nMin Y value = \(minY)\nMax Y value = \(maxY)\nScale = \(scale)\n\nGestures:\nPinch - Zoom\nPan - Move around\nTap - Reset origin to selected location"
    }
    
    
    override func drawRect(rect: CGRect) {
        let graphPath = UIBezierPath()
        var graphAtBeginning: Bool = true
        
        rectWidth = rect.width
        rectHeight = rect.height
        
        //bounds checking to make sure origin coordinates are within rect bounds----
        //sets displacement to their max values if out of bounds
        if centerX < 0 {
            displacementX = -rect.width/2
        } else if centerX > rect.width{
            displacementX = rect.width/2 - 1
        }
        
        if centerY < 0 {
            displacementY = -rect.height/2
        } else if centerY > rect.height{
            displacementY = rect.height/2 - 1
        }
        //----------------------------------------------------------------------------
        
        
        for var x: Double = 0; x <= Double(rect.width); x+=1{
            if let test = dataSource?.graphValue(self, mValue: (x-Double(centerX))/Double(scale)) {
                var convertedY: Double = Double(centerY) - test * Double(scale)
                if graphAtBeginning {
                    graphPath.moveToPoint(CGPoint(x: x, y: convertedY))
                    graphAtBeginning = false
                } else {
                    graphPath.addLineToPoint(CGPoint(x: x, y: convertedY))
                    graphPath.lineWidth = 1
                    graphPath.stroke()
                }
            }
        }
        
        
        var axes = AxesDrawer()
        axes.drawAxesInRect(rect, origin: CGPoint(x: centerX, y: centerY), pointsPerUnit: scale)
        
    }
    

}
