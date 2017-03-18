//
//  ViewController.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 13.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit
import PureLayout
import Sensitive
import RxSwift
import RxCocoa
import IGListKit

class ViewController: UIViewController {
    // MARK: Boilerplate
    let ui = ViewControllerUI()
    let disposeBag = DisposeBag()
    lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(updater: IGListAdapterUpdater(), viewController:self, workingRangeSize: 0)
        adapter.dataSource = self
        return adapter
    }()
    
    override func loadView() {
        view = ui.view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        viewModel.peers.asObservable()
//            .map { $0.map { $0.displayName }.joined(separator: "\n") }
//            .bindTo(counterlabel.rx.text)
//            .addDisposableTo(disposeBag)
        
        adapter.collectionView = ui.collectionView
    }
    
    // MARK: Configuration
    let viewModel = ChatRoomViewModel()
    
}

extension ViewController: IGListAdapterDataSource {
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return viewModel.messages.value
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        // FIXME: labelclass
        return IGListSingleSectionController(cellClass: UICollectionViewCell.self, configureBlock: { (object, cell) in
            return cell
        }, sizeBlock: { (object, context) -> CGSize in
            guard let context = context else {
                return .zero
            }
            // FIXME: dynamic height
            return CGSize(width: context.containerSize.width, height: 55)
        })
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }
}

class ViewControllerUI {
    lazy var view: UIView = {
        let newView = UIView()
        newView.backgroundColor = .green
        
        newView.addSubview(self.peersLabel)
        self.peersLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        newView.addSubview(self.collectionView)
        self.collectionView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        self.collectionView.autoPinEdge(.top, to: .bottom, of: self.peersLabel)
        
        return newView
    }()
    
    let peersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let collectionView: IGListCollectionView = {
        return IGListCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }()
}
