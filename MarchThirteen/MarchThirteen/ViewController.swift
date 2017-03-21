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
        chatRoom.messagesChanged = messagesChanged
        chatRoom.typingStatusChanged = typingStatusChanged
        chatRoom.usersChanged = usersChanged
    }
    
    // MARK: Model
    let chatRoom = ChatRoom()
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
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // Send start typing message when the textfield has one character
        guard textView.text?.characters.count == 1 else { return }
        chatRoom.sendStartTyping()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatRoom.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        let data = chatRoom.messages[indexPath.row]
        let text: String
        if case let .message(messageText) = data.event {
            text = messageText
        } else {
            text = ""
        }
        return JSQMessage(senderId: data.username, displayName: data.username, text: text)
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
        let data = chatRoom.messages[indexPath.row]
        guard let image = UIImage.initialsImage(for: data.username) else {
            return nil
        }
        return JSQMessagesAvatarImage(avatarImage: image, highlightedImage: nil, placeholderImage: image)
    }
}

// MARK: - Chat Room Callbacks
extension ViewController {
    func messagesChanged() {
        DispatchQueue.main.async {
            self.finishReceivingMessage(animated: true)
        }
    }
    
    func typingStatusChanged(shouldShowTypingIndicator: Bool) {
        DispatchQueue.main.async {
            self.showTypingIndicator = shouldShowTypingIndicator
        }
    }
    
    func usersChanged(users: [String]) {
        DispatchQueue.main.async {
            self.title = users.joined(separator: ", ")
        }
    }
}
