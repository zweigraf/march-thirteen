//
//  ConfigurableCollectionViewCell.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 19.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit

protocol ConfigurableCollectionViewCell: class {
    associatedtype ModelType
    
    func configure(with model: ModelType)
}
