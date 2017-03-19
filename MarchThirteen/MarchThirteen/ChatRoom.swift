//
//  ChatRoom.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit

struct Payload {
    let text: String
}

extension Payload: CommunicatorPayload {
    init?(from dictionary: [String : Any]) {
        guard let text = dictionary["text"] as? String else {
            return nil
        }
        self.init(text: text)
    }
    var dictionaryRepresentation: [String : Any] {
        return ["text": text]
    }
}

class ChatMessage: NSObject, CommunicatorOutput {
    let text: String
    let username: String
    
    init(text: String, username: String) {
        self.text = text
        self.username = username
        super.init()
    }

    typealias PayloadType = Payload
    
    required init(from message: CommunicatorMessage<PayloadType>) {
        text = message.payload.text
        username = message.peer.name
        super.init()
    }
}

class ChatRoom {
    
    fileprivate lazy var communicator: Communicator<ChatMessage>  = {
        return Communicator(identifier: "marchthirteen", ownPeerID: self.ownName)
    }()
    
    let ownName = UIDevice.current.name
    var messages = [ChatMessage]()
    var messagesChanged: (() -> Void)?
    
    init() {
        communicator.messageReceived = receive
        communicator.messageSent = receive
//        communicator.peersChanged
    }
    
    func send(message: String) {
        let payload = Payload(text: message)
        communicator.send(message: payload)
    }
    
    func receive(message: ChatMessage) {
        messages.append(message)
        messagesChanged?()
    }
}
