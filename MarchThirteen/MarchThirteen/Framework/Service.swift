//
//  Service.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 14.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum ServiceError: Error {
    case noConnectedPeers
}

internal class Service: NSObject {
    // MARK: 🔓 Public Properties 🔓
    
    typealias PeersChangedCallback = (_ peers: [MCPeerID]) -> Void
    typealias DataReceivedCallback = (_ data: Data, _ peer: MCPeerID) -> Void
    
    /// The list of currently connected peers (peers in state MCSessionState.connected).
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }

    /// The peer id of the local user.
    fileprivate let ownPeer: MCPeerID

    /// This callback will be called when the list of connected peers changes.
    var peersChanged: PeersChangedCallback?
    /// This callback will be called when the session receives data from one of
    /// the connected peers.
    var dataReceived: DataReceivedCallback?
    
    /// Initializes the service manager with a given service type and peerID.
    ///
    /// - Parameters:
    ///   - type: A MultiPeer service type. Service type must be a unique
    ///     string, at most 15 characters long and can contain only ASCII lowercase
    ///     letters, numbers and hyphens.
    ///   - peerID: The user's own peer id to be shown to others.
    init(with type: String, as peerID: MCPeerID) {
        self.type = type
        self.ownPeer = peerID
        super.init()
    }
    
    // MARK: 🔒 Private Properties 🔒

    /// The type that is used for advertising and browsing the service.
    fileprivate let type: String
    
    /// Session used for communicating with peers.
    fileprivate lazy var session: MCSession = {
        let session = MCSession(
            peer: self.ownPeer, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    /// Advertises our peer to others.
    fileprivate lazy var serviceAdvertiser: MCNearbyServiceAdvertiser = {
        let advertiser = MCNearbyServiceAdvertiser(
            peer: self.ownPeer, discoveryInfo: nil, serviceType: self.type)
        advertiser.delegate = self
        return advertiser
    }()
    
    /// Browses for other peers.
    fileprivate lazy var serviceBrowser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(
            peer: self.ownPeer, serviceType: self.type)
        browser.delegate = self
        return browser
    }()
    
    deinit {
        // Stop MultiPeer Stuff
        stop()
    }
    
}

// MARK: - 🔓 Public API 🔓
extension Service {
    /// Starts advertising & browsing for our service.
    func start() {
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    /// Stops advertising & browsing for our service.
    func stop() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    /// Tries to send given data to all connected peers.
    ///
    /// - Parameter data: data to be sent to peers.
    func send(data: Data) throws {
        guard session.connectedPeers.count > 0 else {
            throw ServiceError.noConnectedPeers
        }
        try session.send(
            data, toPeers: session.connectedPeers, with: .reliable)
    }
}

// MARK: - 🔒 Private Delegate Processing 🔒
fileprivate extension Service {
    func notifyReceive(data: Data, from peer: MCPeerID) {
        dataReceived?(data, peer)
    }
    
    func notifyPeersChanged(peers: [MCPeerID]) {
        peersChanged?(peers)
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension Service: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void) {
     
        // Automatically accept all invitations that we get
        invitationHandler(true, session)
    }
    
    // NOOPs
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        // TODO: Handle advertising start errors
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension Service: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Automatically invite all peers we find
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // NOOPs
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // TODO: handle pending / invitable peers
    }
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        // TODO: Handle browsing start errors
    }
}

// MARK: - MCSessionDelegate
extension Service: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        notifyPeersChanged(peers: connectedPeers)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        notifyReceive(data: data, from: peerID)
    }
    
    // NOOPs
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {}
}
