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
public struct CommunicatorMessage<PayloadType: CommunicatorMappable> {
    /// The payload of the message as sent by the other party.
    let payload: PayloadType
    /// The peer that sent this message.
    let peer: Peer
    
    // TODO: add timestamps & figure out way to synchronise devices times
}

// MARK: - Data In/Out
internal extension CommunicatorMessage {
    fileprivate init?(from dictionary: [String : Any], peer: Peer) {
        guard let payloadDict = dictionary[DictionaryKeys.payload.rawValue] as? [String: Any],
            let payload = PayloadType(from: payloadDict) else {
                return nil
        }
        self.init(payload: payload, peer: peer)
    }
    
    fileprivate var dictionaryRepresentation: [String : Any] {
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
        // Wrap payload in dictionary to later attach metadata for ourselves
        let dictionary = dictionaryRepresentation
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        return data
    }
}
