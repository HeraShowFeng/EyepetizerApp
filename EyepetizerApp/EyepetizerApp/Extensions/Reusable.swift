//
//  Reusable.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/16.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier : String {
        return NSStringFromClass(Self.self)
    }
}

public extension UICollectionView {
    func registerClass<T : UICollectionView>(cellClass : T.Type) where T : Reusable {
        self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
}
