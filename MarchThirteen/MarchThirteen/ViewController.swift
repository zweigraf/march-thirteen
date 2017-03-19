//
//  ViewController.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 13.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit
import PureLayout
import Sensitive
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {
    let startTime = mach_absolute_time()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyScrollsToMostRecentMessage = true
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendRunTime), userInfo: nil, repeats: true)
        
        chatRoom.messagesChanged = messagesChanged
    }
    
    // MARK: Model
    let chatRoom = ChatRoom()
    
    func sendRunTime() {
        chatRoom.send(message: "Runtime: \(mach_absolute_time() - startTime). Now that we know who you are, I know who I am. I'm not a mistake! It all makes sense! In a comic, you know how you can tell who the arch-villain's going to be? He's the exact opposite of the hero. And most times they're friends, like you and me! I should've known way back when... You know why, David? Because of the kids. They called me Mr Glass.")
    }
}

// MARK: - JSQMessagesViewController Overrides 
extension ViewController {
    override func senderId() -> String {
        return chatRoom.ownName
    }
    
    override func senderDisplayName() -> String {
        return chatRoom.ownName
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        chatRoom.send(message: text)
        finishSendingMessage(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatRoom.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        let data = chatRoom.messages[indexPath.row]
        return JSQMessage(senderId: data.username, displayName: data.username, text: data.text)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
        let data = self.collectionView(collectionView, messageDataForItemAt: indexPath)
        switch(data.senderId()) {
        case senderId():
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
}

// MARK: - Chat Room Callbacks
extension ViewController {
    func messagesChanged() {
        DispatchQueue.main.async {
            self.finishSendingMessage(animated: true)

        }
    }
}
