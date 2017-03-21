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

// MARK: - Type Def
public class Communicator<OutputType: CommunicatorOutput> {
    // MARK: Public Properties
    var messageReceived: MessageReceivedCallback?
    var messageSent: MessageSentCallback?
    var peersChanged: PeersChangedCallback?
    
    init(identifier: String, ownPeerID: String) {
        let peerID = MCPeerID(displayName: ownPeerID)
        self.ownPeerID = peerID
        
        service = Service(with: identifier, as: peerID)
        
        service.dataReceived = didReceive
        service.peersChanged = peersChanged
        
        service.start()
    }
    
    // MARK: Type Aliases
    fileprivate typealias PayloadType = OutputType.PayloadType
    typealias Message = CommunicatorMessage<OutputType.PayloadType>
    typealias Output = OutputType
    typealias MessageReceivedCallback = (OutputType) -> Void
    typealias MessageSentCallback = (OutputType) -> Void
    typealias PeersChangedCallback = ([Peer]) -> Void
    
    // MARK: Private Properties
    fileprivate let service: Service
    fileprivate let ownPeerID: MCPeerID
}

// MARK: - ⬆️ Sending ⬆️
public extension Communicator {
    func send(message: PayloadType) {
        let message = Message(payload: message, peer: Peer(peerID: ownPeerID))
        let data = message.dataRepresentation
        do {
            try service.send(data: data)
            let output = OutputType(from: message)
            messageSent?(output)
        } catch {}
    }
}

// MARK: - 📞 Callbacks 📞
fileprivate extension Communicator {
    func didReceive(data: Data, from peer: MCPeerID) {
        guard let message = Message(from: data, peer: Peer(peerID: peer)) else {
            return
        }
        let output = OutputType(from: message)
        messageReceived?(output)
    }
    
    func peersChanged(peers: [MCPeerID]) {
        let peers = peers.map { Peer(peerID: $0) }
        peersChanged?(peers)
    }
}
