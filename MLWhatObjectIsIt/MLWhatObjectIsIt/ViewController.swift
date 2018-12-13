//
//  ViewController.swift
//  MLWhatObjectIsIt
//
//  Created by Samman Thapa on 12/12/18.
//  Copyright © 2018 Samman Thapa. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifier: UILabel!
    
    // CoreML Model
    var model: Inceptionv3!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        model = Inceptionv3()
    }
    
    // MARK: - IBActions
    @IBAction func onTapCamera(_ sender: Any)
    {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
    }
    
    
    @IBAction func onTapLibrary(_ sender: Any)
    {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

extension ViewController: UINavigationControllerDelegate
{
    // using https://www.appcoda.com/coreml-introduction/
}


extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true)
        
        // retrieve the selected image from the info dictionary
        classifier.text = "Analyzing Image..."
//        "UIImagePickerControllerOriginalImage"
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        // convert the image into a square, then assign the square image to another constant newImage
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Convert the newImage into a CVPixelBuffer (an image buffer which holds the pixels in the main memory)
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        // take all the pixels present in the image and convert them into a device-dependent RGB color space
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        // Then, by creating all this data into a CGContext, we can easily call it whenever we need to render (or change) some of its underlying properties, like this:
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // make the graphics context into the current context, render the image, remove the context from the top stack
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        // set imageView.image to the newImage
        imageView.image = newImage
        
        // COREML Magic: Predict
        guard let prediction = try? model.prediction(image: pixelBuffer!) else
        {
            return
        }
        
        // Since all CoreML lines are synchornous, we call this only after we get the prediction (my guess)
        classifier.text = "I think this is a \(prediction.classLabel)."
    }
}
