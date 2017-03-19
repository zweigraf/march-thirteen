//
//  ChatRoom.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation

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
    fileprivate let communicator = Communicator<ChatMessage>(identifier: "marchthirteen")
    
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
