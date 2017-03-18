//
//  ServiceManager.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 14.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ServiceManager: NSObject {
    // MARK: Public Shit
    
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
    
    // MARK: Private MC Session Stuff

    /// The service type that is used for advertising and browsing.
    fileprivate let serviceType: String
    
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
            peer: self.ownPeer, discoveryInfo: nil, serviceType: self.serviceType)
        advertiser.delegate = self
        return advertiser
    }()
    
    /// Browses for other peers.
    fileprivate lazy var serviceBrowser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(
            peer: self.ownPeer, serviceType: self.serviceType)
        browser.delegate = self
        return browser
    }()
    
    /// Initializes the service manager with a given service type and peerID.
    ///
    /// - Parameters:
    ///   - serviceType: A MultiPeer service type. Service type must be a unique 
    ///     string, at most 15 characters long and can contain only ASCII lowercase 
    ///     letters, numbers and hyphens.
    ///   - peerID: The user's own peer id to be shown to others.
    init(for serviceType: String, as peerID: MCPeerID) {
        self.serviceType = serviceType
        self.ownPeer = peerID
        super.init()
    }
    
    deinit {
        // Stop MultiPeer Stuff
        stopService()
    }
    
}

// MARK: - Public API
extension ServiceManager {
    /// Starts advertising & browsing for our service.
    func startService() {
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    /// Stops advertising & browsing for our service.
    func stopService() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    /// Tries to send given data to all connected peers.
    ///
    /// - Parameter data: data to be sent to peers.
    func send(data: Data) {
        guard session.connectedPeers.count > 0 else { return }
        do {
            try session.send(
                data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Sending of data failed with error \(error)")
        }
    }
}

// MARK: - Private Delegate Processing
fileprivate extension ServiceManager {
    func notifyReceive(data: Data, from peer: MCPeerID) {
        dataReceived?(data, peer)
    }
    
    func notifyPeersChanged(peers: [MCPeerID]) {
        peersChanged?(peers)
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension ServiceManager: MCNearbyServiceAdvertiserDelegate {
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
extension ServiceManager: MCNearbyServiceBrowserDelegate {
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
extension ServiceManager: MCSessionDelegate {
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
