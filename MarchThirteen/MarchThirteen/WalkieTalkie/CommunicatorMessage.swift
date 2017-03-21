//
//  CommunicatorMessage.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation

fileprivate enum DictionaryKeys: String {
    case meta
    case payload
}

/// Represents a message.
public struct CommunicatorMessage<PayloadType: CommunicatorPayload> {
    /// The payload of the message as sent by the other party.
    public let payload: PayloadType
    /// The peer that sent this message.
    public let peer: Peer
    
    // TODO: add timestamps & figure out way to synchronise devices times
}

// MARK: - ↔️ Data In/Out ↔️
internal extension CommunicatorMessage {
    private init?(from dictionary: [String : Any], peer: Peer) {
        guard let payloadDict = dictionary[DictionaryKeys.payload.rawValue] as? [String: Any],
            let payload = PayloadType(from: payloadDict) else {
                return nil
        }
        self.init(payload: payload, peer: peer)
    }
    
    private var dictionaryRepresentation: [String : Any] {
        // Wrap payload in dictionary to later attach metadata for ourselves
        // Do not serialise the peer, that will not be transferred.
        let dictionary: [String: Any] = [
            DictionaryKeys.payload.rawValue: payload.dictionaryRepresentation
        ]
        return dictionary
    }
    
    init?(from data: Data, peer: Peer) {
        guard let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] else {
            return nil
        }
        self.init(from: dictionary, peer: peer)
    }
    
    var dataRepresentation: Data {
        let dictionary = dictionaryRepresentation
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        return data
    }
}
