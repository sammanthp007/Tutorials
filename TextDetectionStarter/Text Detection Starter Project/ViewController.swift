//
//  ViewController.swift
//  Text Detection Starter Project
//
//  Created by Sai Kambampati on 6/21/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController
{
    
    @IBOutlet weak var imageView: UIImageView!
    
    // Used whenever you want to perform some actions based on a live stream
    var session = AVCaptureSession()
    
    // Vision requests
    var requests = [VNRequest]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        startLiveVideo()
        startTextDetection()
    }
    
    override func viewDidLayoutSubviews()
    {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    func startLiveVideo()
    {
        // 1 Create a session to capture video at high quality
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) // gets us livestream
        
        // 2 set the input and output of the session
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!) // The default camera
        let deviceOutput = AVCaptureVideoDataOutput() // what the video should appear as
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)] // video format
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        // 3 Add the video capturing to screen
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }
}

// MARK: - Vision requests
extension ViewController
{
    func startTextDetection()
    {
        // Create a VNRequest that only looks for rectangles with some text in them
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textRequest.reportCharacterBoxes = true
        self.requests = [textRequest]
    }
    
    func detectTextHandler(request: VNRequest, error: Error?)
    {
        guard let observations = request.results else
        {
            print ("No result, bruv")
            return
        }
        
        let result = observations.map({$0 as? VNTextObservation}) // transform all observations in to type VNTextObservation
        
        DispatchQueue.main.async {
            // remove the bottommost layers
            self.imageView.layer.sublayers?.removeSubrange(1...)
            
            for region in result
            {
                guard let rg = region else
                { continue }
                
                self.highlightWord(box: rg)
                
                if let boxes = region?.characterBoxes
                {
                    for characterBox in boxes
                    {
                        self.highlightLetters(box: characterBox)
                    }
                }
            }
        }
    }
}

// MARK: - Draw boxes
extension ViewController
{
    func highlightWord(box: VNTextObservation)
    {
        // All boxes that were recognized as text boxes
        guard let boxes = box.characterBoxes else
        {
            return
        }
        
        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0
        
        for char in boxes
        {
            if char.bottomLeft.x < maxX
            {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX
            {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY
            {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY
            {
                minY = char.topRight.y
            }
        }
        
        let xCord = maxX * imageView.frame.size.width
        let yCord = (1 - minY) * imageView.frame.size.height
        let width = (minX - maxX) * imageView.frame.size.width
        let height = (minY - maxY) * imageView.frame.size.height
        
        // Draw a box around each word
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
        
        imageView.layer.addSublayer(outline)
    }
    
    func highlightLetters(box: VNRectangleObservation)
    {
        let xCord = box.topLeft.x * imageView.frame.size.width
        let yCord = (1 - box.topLeft.y) * imageView.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
        
        // Draw a box around each letter
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        imageView.layer.addSublayer(outline)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate
{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        // check if sampleBuffer exists and is giving us AVCaptureOutput
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else
        { return }
        
        // VNImageOption type can hold properites and data from camera
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        // On getting all the requests, handle the requests
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}
