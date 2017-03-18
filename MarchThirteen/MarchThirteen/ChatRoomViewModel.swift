//
//  ChatRoomViewModel.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 17.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation
import RxSwift
import IGListKit

struct Peer {
    let name: String
}

struct Message {
    let sender: Peer
    let text: String
}

class MessageViewModel {
    let id = UUID()
    let messageLabelText = Variable<String>("")
    let peerLabelText = Variable<String>("")
    
    init(message: Message) {
        messageLabelText.value = message.text
        peerLabelText.value = message.sender.name
    }
}

extension MessageViewModel: IGListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return id.uuidString as NSString
    }
    
    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        guard let vm = object as? MessageViewModel else {
            return false
        }
        return messageLabelText.value == vm.messageLabelText.value
            && peerLabelText.value == vm.peerLabelText.value
    }
}

class ChatRoomViewModel {
    var messages = Variable<[MessageViewModel]>([])
    let peersLabelText = Variable<String>("")
    
    init() {
        serviceManager.peers.asObservable()
        .bindNext { [weak self] (peers) in
             self?.peersLabelText.value = peers.map { $0.displayName }.joined(separator: ",")
        }
        .addDisposableTo(disposeBag)
    }

    // MARK: Private Stuff
    private let serviceManager = ServiceManager()
    private let disposeBag = DisposeBag()
    
}
