//
//  SignalView.swift
//  PGprojekat
//
//  Created by Uros Zivaljevic on 12/20/15.
//  Copyright © 2015 Uros Zivaljevic. All rights reserved.
//

import UIKit

class SignalView: UIView {

    var bgImage: CGImageRef!
    
    
    var data:[Double]! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    func prepBgImage(){
        
        let rect = self.bounds;
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
            let space = CGColorSpaceCreateDeviceRGB();
            let ctx = CGBitmapContextCreate(nil, Int(rect.size.width), Int(rect.size.height), 8, Int(rect.size.width) * (CGColorSpaceGetNumberOfComponents(space) + 1), space, CGImageAlphaInfo.PremultipliedLast.rawValue);
            CGContextMoveToPoint(ctx, -2, self.bounds.size.height/2)
            CGContextSetStrokeColorWithColor(ctx, UIColor.redColor().CGColor);
            CGContextSetLineWidth(ctx, 0.5);
            if self.data != nil {
                let pixelScale = self.bounds.size.width/CGFloat(self.data.count)
                for i in 0..<self.data.count {
                    CGContextAddLineToPoint(ctx, CGFloat(i)*pixelScale, -CGFloat(sqrt(self.data[i])/Double(self.bounds.size.height/2))+self.bounds.size.height/2)
//                    path.addLineToPoint(CGPoint(x: Double(Double(i)*Double(pixelScale)),y: self.data[i]))
                    
                }
                 CGContextStrokePath(ctx);
            }
            
            self.bgImage = CGBitmapContextCreateImage(ctx);
            
            dispatch_async(dispatch_get_main_queue()){
               self.setNeedsDisplayInRect(rect)
            }
        
        }
        
    }
    
    override func drawRect(rect: CGRect) {
        
        
        let ctx = UIGraphicsGetCurrentContext();
       
        CGContextDrawImage(ctx, self.bounds, bgImage);
        
    }


}
