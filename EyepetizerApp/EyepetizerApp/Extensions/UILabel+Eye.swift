//
//  UILabel+Eye.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/23.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import Foundation

extension UILabel {
    func boundingRectWithSize(size : CGSize) -> CGSize {
        let attribute = [NSAttributedStringKey.font: self.font]
        
        let retSize = (self.text! as NSString).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attribute, context: nil).size
        return retSize
    }
}
