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
        chatRoom.send(message: "Runtime: \(mach_absolute_time() - startTime). Now that we know who you are, I know who I am. I'm not a mistake! It all makes sense! In a comic, you know how you can tell who the arch-villain's going to be? He's the exact opposite of the hero. And most times they're friends, like you and me! I should've known way back when... You know why, David? Because of the kids. They called me Mr Glass.")
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
        return SelfSizingCellSectionController<MessageCollectionViewCell>()
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
        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = CGSize(width: 100, height: 50)
        let view = IGListCollectionView(frame: .zero, collectionViewLayout: layout)
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
