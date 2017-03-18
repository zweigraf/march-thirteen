//
//  ChatRoom.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 18.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import Foundation

fileprivate struct Payload {
    let message: String
}

extension Payload: CommunicatorMappable {
    init?(from dictionary: [String : Any]) {
        self.init(message: "")
    }
    fileprivate var dictionaryRepresentation: [String : Any] {
        return [:]
    }
}

class ChatRoom {
    fileprivate let communicator = Communicator<Payload>(identifier: "marchthirteen")
}
