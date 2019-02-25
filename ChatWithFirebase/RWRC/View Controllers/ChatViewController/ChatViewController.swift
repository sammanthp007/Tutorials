/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Firebase
import MessageKit
import FirebaseFirestore
import Photos

final class ChatViewController: MessagesViewController
{
  private var messages: [Message] = []
  private var messageListener: ListenerRegistration?
  
  private let db = Firestore.firestore()
  var reference: CollectionReference?
  
  let user: User
  let channel: Channel
  
  var isSendingPhoto = false {
    didSet {
      DispatchQueue.main.async {
        self.messageInputBar.leftStackViewItems.forEach { item in
          item.isEnabled = !self.isSendingPhoto
        }
      }
    }
  }
  
  let storage = Storage.storage().reference()
  
  init(user: User, channel: Channel)
  {
    self.user = user
    self.channel = channel
    super.init(nibName: nil, bundle: nil)
    
    title = channel.name
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad()
  {
    guard let id = channel.id else
    {
      navigationController?.popViewController(animated: true)
      return
    }
    
    // Listen and handle new messages
    reference = db.collection(["channels", id, "thread"].joined(separator: "/"))
    messageListener = reference?.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }
    
    super.viewDidLoad()
    
    navigationItem.largeTitleDisplayMode = .never
    
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .primary
    messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    addCameraButton()
  }
  
  private func insertNewMessage(_ message: Message)
  {
    guard !messages.contains(message) else
    { return }
    
    messages.append(message)
    messages.sort()
    
    let isLatestMessage = messages.index(of: message) == (messages.count - 1)
    let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
    
    messagesCollectionView.reloadData()
    
    if shouldScrollToBottom
    {
      DispatchQueue.main.async {
        self.messagesCollectionView.scrollToBottom(animated: true)
      }
    }
  }
  
  private func handleDocumentChange(_ change: DocumentChange)
  {
    guard var message = Message(document: change.document) else
    { return }
    
    switch change.type
    {
    case .added:
      if let url = message.downloadURL
      {
        downloadImage(at: url) { [weak self] image in
          guard let self = self else {
            return
          }
          guard let image = image else {
            return
          }
          
          message.image = image
          self.insertNewMessage(message)
        }
      }
      else
      {
        insertNewMessage(message)
      }
      
    default:
      break
    }
  }
  
  deinit {
    messageListener?.remove()
  }
  
  // MARK: Private View Constructors
  private func addCameraButton()
  {
    // 1
    let cameraItem = InputBarButtonItem(type: .system)
    cameraItem.tintColor = .primary
    cameraItem.image = UIImage(named: "camera")
    
    // 2
    cameraItem.addTarget(
      self,
      action: #selector(cameraButtonPressed),
      for: .primaryActionTriggered
    )
    cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
    
    messageInputBar.leftStackView.alignment = .center
    messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
    
    // 3
    messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
  }
  
  // MARK: - Actions
  
  @objc private func cameraButtonPressed()
  {
    let picker = UIImagePickerController()
    picker.delegate = self
    
    if UIImagePickerController.isSourceTypeAvailable(.camera)
    {
      picker.sourceType = .camera
    }
    else
    {
      picker.sourceType = .photoLibrary
    }
    
    present(picker, animated: true, completion: nil)
  }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate
{
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor
  {
    return isFromCurrentSender(message: message) ? .primary: .incomingMessage
  }
  
  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool
  {
    if indexPath.section % 2 == 0
    {
      return true
    }
    return false
  }
  
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle
  {
    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    
    return .bubbleTail(corner, MessageStyle.TailStyle.pointedEdge)
  }
}

extension ChatViewController: MessagesLayoutDelegate
{
  func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize
  {
    let currentMessageIndex = indexPath.section
    let indexOfMessageOneBefore = currentMessageIndex - 1
    
    if indexOfMessageOneBefore >= 0,
      messages[indexOfMessageOneBefore].sender.id == messages[currentMessageIndex].sender.id
    {
      return .zero
    }
    
    return CGSize(width: 30, height: 30)
  }
  
  func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize
  {
    return CGSize(width: 0, height: 8)
  }
  
  func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat
  {
    return 0
  }
}

extension ChatViewController: MessagesDataSource
{
  func currentSender() -> Sender
  {
    return Sender(id: user.uid, displayName: AppSettings.displayName)
  }
  
  func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int
  {
    return messages.count
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType
  {
    return messages[indexPath.section]
  }
  
  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
  {
    let currentMessageIndex = indexPath.section
    let indexOfMessageOneBefore = currentMessageIndex - 1
    
    if indexOfMessageOneBefore >= 0,
      messages[indexOfMessageOneBefore].sender.id == messages[currentMessageIndex].sender.id
    {
      return nil
    }
      
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ]
    )
  }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate
{
  func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String)
  {
    let message = Message(user: user, content: text)
    
    save(message)
    
    inputBar.inputTextView.text = ""
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
  {
    picker.dismiss(animated: true, completion: nil)
    
    // 1
    if let asset = info[.phAsset] as? PHAsset
    {
      let size = CGSize(width: 500, height: 500)
      PHImageManager.default().requestImage(
        for: asset,
        targetSize: size,
        contentMode: .aspectFit,
        options: nil) { result, info in
          
          guard let image = result else {
            return
          }
          
          self.sendPhoto(image)
      }
      
      // 2
    }
    else if let image = info[.originalImage] as? UIImage
    {
      sendPhoto(image)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
  {
    picker.dismiss(animated: true, completion: nil)
  }
}
