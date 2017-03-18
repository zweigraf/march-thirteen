//
//  Communicator.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

// FIXME: Can also be injected or created otherwise.
fileprivate let ownPeerID = MCPeerID(displayName: UIDevice.current.name)

// MARK: - Type Def
public class Communicator<PayloadType: CommunicatorMappable> {
    // MARK: Type Aliases
    typealias Message = CommunicatorMessage<PayloadType>
    typealias MessageReceivedCallback = (Message) -> Void
    typealias MessageSentCallback = (Message) -> Void
    typealias PeersChangedCallback = ([Peer]) -> Void
    
    init(identifier: String) {
        service = Service(with: identifier, as: ownPeerID)
        
        service.dataReceived = didReceive
        service.peersChanged = peersChanged
        
        service.start()
    }
    
    // MARK: Private Properties
    fileprivate let service: Service
}

// MARK: - ⬆️ Sending ⬆️
public extension Communicator {
    func send(message: PayloadType) {
        let message = Message(payload: message, peer: Peer(peerID: ownPeerID))
        let data = message.dataRepresentation
        do {
            try service.send(data: data)
            // FIXME: call message sent callback
        } catch {}
    }
}

// MARK: - 📞 Callbacks 📞
fileprivate extension Communicator {
    func didReceive(data: Data, from peer: MCPeerID) {
        guard let message = Message(from: data, peer: Peer(peerID: peer)) else {
            return
        }
        // FIXME: call message received callback
    }
    
    func peersChanged(peers: [MCPeerID]) {
        let peers = peers.map { Peer(peerID: $0) }
        // FIXME: call peers changed callback
    }
}
