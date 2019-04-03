//
//  ViewController.swift
//  ImageDetector
//
//  Created by Adheena Sanish on 2019-04-03.
//  Copyright © 2019 Adheena Sanish. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    let captureSession = AVCaptureSession()
    captureSession.sessionPreset = .photo
    guard let captureDevice  = AVCaptureDevice.default(for: .video) else { return }
    guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return  }
    captureSession.addInput(input)
    captureSession.startRunning()
    let previewLayer  =  AVCaptureVideoPreviewLayer(session: captureSession)
    view.layer.addSublayer(previewLayer)
    previewLayer.frame = view.frame
    
    let dataOutput = AVCaptureVideoDataOutput()
    dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label:"videoQueue"))
    captureSession.addOutput(dataOutput)
    
//    let request  = VNCoreMLRequest(model: <#T##VNCoreMLModel#>, completionHandler: <#T##VNRequestCompletionHandler?##VNRequestCompletionHandler?##(VNRequest, Error?) -> Void#>)
//
  //  VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
    
  }

  func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    //print("Camera was able to capture a frame:",Date())
    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return}
    
    
    guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else { return }
    
    //
    
    let request  = VNCoreMLRequest(model: model)
    {(finishdReq, err) in
     // print(finishdReq.results)
      guard let results = finishdReq.results as? [VNClassificationObservation] else { return }
      guard let firstObservation = results.first else { return }
      print(firstObservation.identifier,firstObservation.confidence
      )
      
    }
    
    
    
   
    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
  }
}

