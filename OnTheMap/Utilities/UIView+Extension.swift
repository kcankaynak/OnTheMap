//
//  UIView+Extension.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 30.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
