//
//  SelfSizingCellSectionController.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 19.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation
import IGListKit

class SelfSizingCellSectionController<CellClass>: IGListSectionController, IGListSectionType
        where CellClass: ConfigurableCollectionViewCell, CellClass: UICollectionViewCell {
    
    func numberOfItems() -> Int {
        return 1
    }
    
    // MARK: Cell Configuration
    var currentCell: CellClass?
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let item = model,
            let context = collectionContext,
            let cell = context.dequeueReusableCell(of: CellClass.self, for: self, at: index) as? CellClass else {
                fatalError("SelfSizingCellSectionController has no model or CollectionContext")
        }
        cell.configure(with: item)
        self.currentCell = cell
        return cell
    }
    
    func didSelectItem(at index: Int) {
        // TODO: Add selection handler
    }
    
    // MARK: Model
    var model: CellClass.ModelType?
    
    func didUpdate(to object: Any) {
        guard let item = object as? CellClass.ModelType else {
            fatalError("SelfSizingCellSectionController<\(CellClass.ModelType.self)> used with item of type \(type(of: object)).")
        }
        model = item
    }
    
    // MARK: SelfSizing
    lazy var templateCell: CellClass = {
        let cell = CellClass(frame: .zero)
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }()
//    
//    var templateCellWidthConstraint: NSLayoutConstraint?
    
    func sizeForItem(at index: Int) -> CGSize {
//        guard let cell = currentCell else {
//            fatalError("Dont have the cell yet")
//        }
        guard let item = model,
            let context = collectionContext else {
                fatalError("SelfSizingCellSectionController has no CollectionContext or model")
        }
        templateCell.configure(with: item)
        templateCell.setNeedsLayout()
        templateCell.layoutIfNeeded()
        let size = templateCell.contentView.systemLayoutSizeFitting((CGSize(width: context.containerSize.width, height: CGFloat.greatestFiniteMagnitude)), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        return size
        
//        // We want selfsizing, so return .zero for now
//        return CGSize(width: collectionContext!.containerSize.width, height: 5)
//
//        guard let item = model,
//            let context = collectionContext else {
//                fatalError("SelfSizingCellSectionController has no CollectionContext or model")
//        }
//        
//        if let constraint = templateCellWidthConstraint {
//            templateCell.removeConstraint(constraint)
//        }
//        var baseSize = context.containerSize
//        baseSize.height = 0
//        
//        templateCell.configure(with: item)
//        templateCellWidthConstraint = templateCell.contentView.autoSetDimension(.width, toSize: baseSize.width)
//        templateCell.autoSetDimension(.width, toSize: baseSize.width)
//        templateCell.setNeedsLayout()
//        templateCell.layoutIfNeeded()
//        return templateCell.contentView.sizeThatFits(baseSize)
////        return templateCell.contentView.sizeThatFits(baseSize)
////        return templateCell.bounds.size
////        return templateCell.bounds.size
    }
}
