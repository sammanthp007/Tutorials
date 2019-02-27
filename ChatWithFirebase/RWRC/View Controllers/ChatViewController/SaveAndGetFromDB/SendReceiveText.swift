//
//  SendReceiveText.swift
//  RWRC
//
//  Created by Samman Thapa on 2/25/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import Foundation

extension ChatViewController
{
  // Saves a text. Includes links to photos or attachment or just text as needed
  func save(_ message: Message)
  {
    reference?.addDocument(data: message.representation) { error in
      if let e = error
      {
        print("Error sending message: \(e.localizedDescription)")
        return
      }
      
      self.messagesCollectionView.scrollToBottom()
    }
  }
}
