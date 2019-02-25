//
//  SendReceivePhoto.swift
//  RWRC
//
//  Created by Samman Thapa on 2/25/19.
//  Copyright © 2019 Razeware. All rights reserved.
//

import UIKit
import FirebaseStorage

extension ChatViewController
{
  private func uploadImage(_ image: UIImage, to channel: Channel, completion: @escaping (URL?) -> Void)
  {
    guard let channelID = channel.id else
    {
      completion(nil)
      return
    }
    
    guard let scaledImage = image.scaledToSafeUploadSize,
      let data = scaledImage.jpegData(compressionQuality: 0.4) else
    {
      completion(nil)
      return
    }
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
    storage.child(channelID).child(imageName).putData(data, metadata: metadata) { meta, error in
      completion(meta?.downloadURL())
    }
  }
  
  func sendPhoto(_ image: UIImage)
  {
    isSendingPhoto = true
    
    uploadImage(image, to: channel) { [weak self] url in
      guard let `self` = self else {
        return
      }
      self.isSendingPhoto = false
      
      guard let url = url else
      { return }
      
      var message = Message(user: self.user, image: image)
      message.downloadURL = url
      
      self.save(message)
      self.messagesCollectionView.scrollToBottom()
    }
  }
  
  func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void)
  {
    let ref = Storage.storage().reference(forURL: url.absoluteString)
    let megaByte = Int64(1 * 1024 * 1024)
    
    ref.getData(maxSize: megaByte) { data, error in
      guard let imageData = data else
      {
        completion(nil)
        return
      }
      
      completion(UIImage(data: imageData))
      self.messagesCollectionView.scrollToBottom()
    }
  }
}
