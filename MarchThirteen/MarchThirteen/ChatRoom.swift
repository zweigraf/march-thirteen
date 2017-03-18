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

struct ChatMessage {
    let text: String
    let username: String
}

extension ChatMessage: CommunicatorOutput {
    typealias PayloadType = Payload
    
    init(from message: CommunicatorMessage<PayloadType>) {
        self.init(text: message.payload.text, username: message.peer.name)
    }
}

class ChatRoom {
    fileprivate let communicator = Communicator<ChatMessage>(identifier: "marchthirteen")
    
    func send(message: String) {
        let payload = Payload(text: message)
        communicator.send(message: payload)
    }
}
