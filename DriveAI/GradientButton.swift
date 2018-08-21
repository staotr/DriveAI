//
//  GradientButton.swift
//  DriveAI
//
//  Created by Ricardo De Jesus on 7/14/18.
//  Copyright © 2018 AAS. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIButton {
    func setButtonColor(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.00, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        layer.insertSublayer(gradientLayer, at: 1)
    }
    
    func setRadius(input: CGFloat) {
        layer.cornerRadius = input
    }
    
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.1
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        
        // ADD TO BUTTON
        layer.add(flash, forKey: nil)
    }

}
