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
import IGListKit

class ViewController: UIViewController {
    // MARK: Boilerplate
    let ui = ViewControllerUI()
    
    lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(updater: IGListAdapterUpdater(), viewController:self, workingRangeSize: 0)
        adapter.dataSource = self
        return adapter
    }()
    
    override func loadView() {
        view = ui.view
    }
    
    let startTime = mach_absolute_time()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        adapter.collectionView = ui.collectionView
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendRunTime), userInfo: nil, repeats: true)
        
        chatRoom.messagesChanged = messagesChanged
    }
    
    // MARK: Model
    let chatRoom = ChatRoom()
    
    func sendRunTime() {
        chatRoom.send(message: "Runtime: \(mach_absolute_time() - startTime)")
    }
}

// MARK: - Chat Room Callbacks
extension ViewController {
    func messagesChanged() {
        DispatchQueue.main.async {
            self.adapter.performUpdates(animated: true)
        }
    }
}

extension ViewController: IGListAdapterDataSource {
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return chatRoom.messages
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        // FIXME: labelclass
        return IGListSingleSectionController(cellClass: MessageCollectionViewCell.self, configureBlock: { (object, cell) in
            guard let cell = cell as? MessageCollectionViewCell,
                let message = object as? ChatMessage else { return }
            cell.ui.nameLabel.text = message.username
            cell.ui.messageLabel.text = message.text
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
        label.backgroundColor = .lightGray
        return label
    }()
    
    let collectionView: IGListCollectionView = {
        let view = IGListCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .darkGray
        return view
    }()
}

extension ChatMessage: IGListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        guard let other = object as? ChatMessage else {
            return false
        }
        return text == other.text && username == other.username
    }
}
