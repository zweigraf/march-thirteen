//
//  SelfSizingCollectionViewCell.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 19.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation
import ObjectiveC

//let templateCellKey:

protocol SelfSizingCollectionViewCell {
    static var templateCell: Self {
        get {
            objc_getAssociatedObject(self, &AssociatedObjectHandle) as String
        
        }
    }
}
