//
//  UILabel.swift
//  Toy1
//
//  Created by Junhyeon on 2019/09/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit

extension UILabel {
    
    func setLabel( translatesAutoresizingMaskIntoConstraints: Bool, setText: String, setBackground: UIColor, setTextColor: UIColor, textAlignment: NSTextAlignment) {
        
        let label = self
        
        label.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        label.text = setText
        label.backgroundColor = setBackground
        label.textAlignment = textAlignment
    }
}
