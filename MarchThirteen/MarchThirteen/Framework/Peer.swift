//
//  Peer.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation
import MultipeerConnectivity

/// Represents one peer.
public struct Peer {
    /// Name that should be used when displaying this peer.
    let name: String
}

// MARK: - MCPeerID compatibility
internal extension Peer {
    init(peerID: MCPeerID) {
        self.init(name: peerID.displayName)
    }
}
