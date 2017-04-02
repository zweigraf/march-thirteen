//
//  ChatRoom.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit

enum Payload {
    case typingStarted
    case message(text: String)
}

extension Payload: CommunicatorPayload {
    init?(from dictionary: [String : Any]) {
        guard let type = dictionary["type"] as? String else {
            return nil
        }
        
        switch type {
        case "typingStarted":
            self = .typingStarted
        case "message":
            guard let message = dictionary["message"] as? String else {
                return nil
            }
            self = .message(text: message)
        default:
            return nil
        }
    }
    
    var dictionaryRepresentation: [String : Any] {
        switch self {
        case .typingStarted:
            return ["type": "typingStarted"]
        case .message(let text):
            return ["type": "message", "message": text]
        }
    }
}

// Could also be an enum
class ChatEvent: NSObject, CommunicatorOutput {
    typealias PayloadType = Payload
    
    let event: PayloadType
    let username: String
    
    init(event: PayloadType, username: String) {
        self.event = event
        self.username = username
        super.init()
    }

    required init(from message: CommunicatorMessage<PayloadType>) {
        event = message.payload
        username = message.peer.name
        super.init()
    }
}

class ChatRoom {
    fileprivate lazy var communicator: Communicator<ChatEvent> = {
        return Communicator(identifier: "marchthirteen", ownPeerID: self.ownName)
    }()
    
    fileprivate var typingEvents = [ChatEvent]() {
        didSet {
            typingStatusChanged?(typingEvents.count > 0)
        }
    }
    
    let ownName = UIDevice.current.name
    var messages = [ChatEvent]()
    
    var messagesChanged: (() -> Void)?
    var usersChanged: (([String]) -> Void)?
    var typingStatusChanged: ((Bool) -> Void)?
    
    init() {
        communicator.messageReceived = receive
        communicator.messageSent = receive
        communicator.peersChanged = peersChanged
    }
    
    func send(message: String) {
        communicator.send(message: .message(text: message))
    }
    
    func sendStartTyping() {
        communicator.send(message: .typingStarted)
    }
    
    func receive(message: ChatEvent) {
        switch message.event {
        case .typingStarted:
            let weAlreadyHaveThisEvent = typingEvents.filter {
                $0.username == message.username
            }.count > 0
            // Do not count our own typing events or already existing ones
            guard message.username != ownName,
                !weAlreadyHaveThisEvent else { return }
            typingEvents.append(message)
        case .message:
            // Only keep typing events where the username is not that of 
            // the received message (assume that user has finished typing)
            typingEvents = typingEvents.filter {
                $0.username != message.username
            }
            messages.append(message)
            messagesChanged?()
        }
    }
    
    func peersChanged(peers: [Peer]) {
        let userList = peers.map { $0.name }
        usersChanged?(userList)
    }
}
