//
//  CustomImageView.swift
//  SocioNet
//
//  Created by Nishant on 02/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {

    override func awakeFromNib() {
    
        super.awakeFromNib()
        
        layer.cornerRadius = 25.0
    }

}
