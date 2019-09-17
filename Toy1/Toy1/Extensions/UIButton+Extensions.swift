//
//  UIButton+Extension.swift
//  Toy1
//
//  Created by Junhyeon on 2019/09/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setButton( translatesAutoresizingMaskIntoConstraints: Bool, setTitle: String, setBackground: UIColor, setTintColor: UIColor) {
        
        let button = self
        button.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        button.setTitle(setTitle, for: .normal)
        button.backgroundColor = setBackground
        button.tintColor = setTintColor
    }
    
    func setButton( translatesAutoresizingMaskIntoConstraints: Bool, setTitle: String, setBackground: UIColor, setTintColor: UIColor, buttonPositionX: Double, buttonPositionY: Double ,buttonWidth: Double, buttonHeight: Double) {
        
        let button = self
        button.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        button.setTitle(setTitle, for: .normal)
        button.backgroundColor = setBackground
        button.tintColor = setTintColor
        button.frame = CGRect(x: buttonPositionX, y: buttonPositionY, width: buttonWidth, height: buttonHeight)
    }

    
    
}
