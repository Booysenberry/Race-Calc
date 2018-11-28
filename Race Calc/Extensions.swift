//
//  Extensions.swift
//  Race Calc
//
//  Created by Brad Booysen on 28/11/18.
//  Copyright © 2018 Brad Booysen. All rights reserved.
//

import Foundation
import UIKit

// Extension to hide keyboard when user taps around
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// Custom colour for UI
extension UIColor {
    class func getCustomRedColor() -> UIColor{
        return UIColor(red: 234.0/255.0, green: 46.0/255.0, blue: 73.0/255.0, alpha: 1.0)
    }
}

extension UIButton {
    func selectedButton(title:String, iconName: String) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor.getCustomRedColor(), for: .normal)
        self.setImage(UIImage(named: iconName), for: .normal)
//        let imageWidth = self.imageView!.frame.width
//        let textWidth = (title as NSString).size(withAttributes:[NSAttributedString.Key.font:self.titleLabel!.font!]).width
////        let width = textWidth + imageWidth + 24
////        
////        //24 - the sum of your insets from left and right
//////        widthConstraints.constant = width
//////        self.layoutIfNeeded()
    }
}
