//
//  GradientView.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/29/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit
class GradientView: UIView {
    
    override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clearColor()// clear means fully transparent
    autoresizingMask = [.FlexibleWidth , .FlexibleHeight]//This tells the view that it should change both its width and its height proportionally when the superview it belongs to resizes.
    }

    required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
    }
    
    override func drawRect(rect: CGRect) {
        
        let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]// These are two color stops. The first color (0, 0, 0, 0.3) is a black color that is mostly transparent, the second one (0, 0, 0, 0.7) is also black but much less transparent
        let locations: [CGFloat] = [ 0, 1 ]//it's two locations. location 0 represents the center of the screen, and 1 one does its bounds.

        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)// These relics from iOS are called “opaque” types, or “handles”.
        
        let x = CGRectGetMidX(bounds)
        let y = CGRectGetMidY(bounds)//The CGRectGetMidX() and CGRectGetMidY() functions return the center point of a rectangle. That rectangle is given by bounds, a CGRect object that describes the dimensions of the view.
        let point = CGPoint(x: x, y : y)
        let radius = max(x, y)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawRadialGradient(context, gradient, point, 0, point,
        radius, .DrawsAfterEndLocation)
    }
}
