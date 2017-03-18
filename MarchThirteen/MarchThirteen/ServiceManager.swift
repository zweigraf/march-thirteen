//
//  ServiceManager.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 14.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import RxSwift

// Service type must be a unique string, at most 15 characters long
// and can contain only ASCII lowercase letters, numbers and hyphens.
private let chatRoomServiceType = "marchthirteen"
private let myPeerId = MCPeerID(displayName: UIDevice.current.name)

struct NetworkMessage {
    let text: String
}

enum NetworkEvent {
    case message(message: NetworkMessage)
}

class ServiceManager: NSObject {
    // MARK: Public Shit
    let peers = Variable<[MCPeerID]>([myPeerId])
    
    // MARK: Private Shit
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: chatRoomServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: chatRoomServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func send(event: NetworkEvent) {
        guard session.connectedPeers.count > 0 else { return }
        var copy = event
        let data = Data(bytes: &copy, count: MemoryLayout<NetworkEvent>.size(ofValue: event))
        try! self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
    
    func receive(data: Data) {
        let pointer = UnsafeMutableBufferPointer<NetworkEvent>. .alloc(capacity: MemoryLayout<NetworkEvent>.size)
        data.copyBytes(to: pointer)
        
    }
    
    
    
//    func send(counter: Int) {
//        //print("%@", "sendString: \(counter) to \(session.connectedPeers.count) peers")
//        
//        guard session.connectedPeers.count > 0 else { return }
//        do {
//            let data = Data(bytes: [UInt8(counter)])
//            try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
//        }
//        catch let error {
//            //print("%@", "Error for sending: \(error)")
//        }
//        
//    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}

extension ServiceManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //print("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //print("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension ServiceManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //print("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        //print("%@", "foundPeer: \(peerID)")
        //print("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        //print("%@", "lostPeer: \(peerID)")
    }
    
}

extension ServiceManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            var copy = peers.value
            guard copy.index(of: peerID) == nil else { return }
            copy.append(peerID)
            peers.value = copy
        case .notConnected:
            var copy = peers.value
            guard let index = copy.index(of: peerID) else { return }
            copy.remove(at: index)
            peers.value = copy
        default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        let counter = Int(data[0])
        //print("%@", "didReceiveCount: \(counter)")
        
        // FIXME: create messages
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //print("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //print("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        //print("%@", "didFinishReceivingResourceWithName")
    }
    
}
