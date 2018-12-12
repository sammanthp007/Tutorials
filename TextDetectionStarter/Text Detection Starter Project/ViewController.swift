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

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // Used whenever you want to perform some actions based on a live stream
    var session = AVCaptureSession()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        startLiveVideo()
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

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate
{
    
}
