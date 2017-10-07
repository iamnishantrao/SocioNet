//
//  CustomView.swift
//  SocioNet
//
//  Created by Nishant on 02/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit

class CustomView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.5
        layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
    }
}
