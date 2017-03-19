//
//  MessageCollectionViewCell.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 19.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit
import PureLayout

class MessageCollectionViewCell: UICollectionViewCell {
    let ui = MessageCollectionViewCellUI()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(ui.view)
        ui.view.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}

class MessageCollectionViewCellUI {
    lazy var view: UIView = {
        let view = UIView()
        
        view.addSubview(self.nameLabel)
        self.nameLabel.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
        
        view.addSubview(self.messageLabel)
        self.messageLabel.autoPinEdges(toSuperviewMarginsExcludingEdge: .top)
        self.messageLabel.autoPinEdge(.top, to: .bottom, of: self.nameLabel, withOffset: 16)
        
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
}
