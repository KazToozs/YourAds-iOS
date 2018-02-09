//
//  CameraController.swift
//  YourAds PoC
//
//  Created by Cris Toozs on 01/03/2017.
//  Copyright © 2017 Cris Toozs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreImage

class CameraLauncher: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    func showCamera() {
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            let cameraViewFrame = CGRect(x: keyWindow.frame.width / 2 - (keyWindow.frame.width / 3 / 2),
                                         y: 0,
                                         width: keyWindow.frame.width / 3,
                                         height: keyWindow.frame.height / 3)
            let cameraView = CameraView(frame: cameraViewFrame)
            cameraView.backgroundColor = UIColor(white: 1, alpha: 0.5)
            
            
            keyWindow.addSubview(cameraView)
            
        }
    }
}

class CameraView: UIImageView, AVCaptureVideoDataOutputSampleBufferDelegate
{
    
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var previewView: UIView?
    var camera: AVCaptureDevice?
    var outputQueue: DispatchQueue?
    var faceDetector: CIDetector!
    
    override init(frame: CGRect) {
        super.init(frame:frame)

        handleCamera()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleCamera()
    {
        // select the device to use as input: front camera
        camera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                                               for: AVMediaType.video, position: .front)
        // Create a capture session: collect input from devices, modify the output to photos or videos
        session = AVCaptureSession()
        output = AVCaptureVideoDataOutput()
        
        // create the input for use with the session
        do {
            try input = AVCaptureDeviceInput(device: camera!)
        } catch _ as NSError {
            print("error")
            input = nil
        }
        
        // send the camera input to the session
        if(session?.canAddInput(input!) == true){
            
            //Add the input to the session
            session?.addInput(input!)
        }
        
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        let rgbOutputSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCMPixelFormat_32BGRA)]
        
        output?.videoSettings = rgbOutputSettings
        output?.alwaysDiscardsLateVideoFrames = true
        
        outputQueue = DispatchQueue(label: "outputQueue")
        output?.setSampleBufferDelegate(self, queue: outputQueue)
        
        // add front camera output to the session for use and modification
        if(session?.canAddOutput(output!) == true){
            session?.addOutput(output!)

        } // front camera can't be used as output, not working: handle error
        else {
            
        }
        output?.connection(with: AVMediaType.video)?.isEnabled = false

        previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer?.frame = self.bounds
        self.layer.addSublayer(previewLayer!)
        
        let rootLayer = self.previewView?.layer
        rootLayer?.masksToBounds = true
        
        // setup camera preview
        session?.startRunning()
    }
    
        func captureOutput(_ captureOutput: AVCaptureOutput,
                           didOutput sampleBuffer: CMSampleBuffer,
                           from connection: AVCaptureConnection)
        {
            // got an image
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
            let ciImage : CIImage = CIImage(cvPixelBuffer: pixelBuffer!, options: attachments as? [String : AnyObject])
            
            let exifOrientation = 6; //   6  =  0th row is on the right, and 0th column is the top. Portrait mode.
            let imageOptions : NSDictionary = [CIDetectorImageOrientation : NSNumber(value: exifOrientation), CIDetectorSmile : true, CIDetectorEyeBlink : true]

            faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking : true])

            let features = faceDetector.features(in: ciImage, options: imageOptions as? [String : AnyObject])

            
            
            // get the clean aperture
            // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
            // that represents image data valid for display.
            let fdesc : CMFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)!
            let clap : CGRect = CMVideoFormatDescriptionGetCleanAperture(fdesc, false)
            
            // called asynchronously as the capture output is capturing sample buffers, this method asks the face detector
            // to detect features
            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.drawFaceBoxesForFeatures(features, clap: clap, orientation: .portrait)
//            })

            
            DispatchQueue.main.async {
                self.drawFaceBoxesForFeatures(features: features, clap: clap, orientation: UIDevice.current.orientation)
            }
           
    }

    
    
//            DispatchQueue.main.async {
//                let parentFrameSize = self.previewView?.frame.size
//                let gravity = self.previewLayer?.videoGravity
//                
//                var previewBox: CGRect = previewLayer.videoPreviewBox(for: gravity, frameSize: parentFrameSize, apertureSize: clap.size)
//                if self.delegate.responds(to: Selector("detectedFaceController:features:forVideoBox:withPreviewBox:")) {
//                    self.delegate.detectedFaceController(self, features: features, forVideoBox: clap, withPreviewBox: previewBox)
//                }
//                
//            }
    
    
//    func startDetection() {
//        self.handleCamera()
//        self.output?.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
//        var detectorOptions: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyLow]
//        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions)
//    }
    
//    func stopDetection() {
//        self.teardownAVCapture()
//    }
//    // clean up capture setup
//    
//    func teardownAVCapture() {
//        if self.videoDataOutputQueue {
//            self.videoDataOutputQueue = nil
//        }
//    }
            
    
    func drawFaceBoxesForFeatures(features : [CIFeature], clap : CGRect, orientation : UIDeviceOrientation) {
        
        let sublayers : NSArray = previewLayer!.sublayers! as NSArray
        let sublayersCount : Int = sublayers.count
        var currentSublayer : Int = 0
        //        var featuresCount : Int = features.count
        var currentFeature : Int = 0
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // hide all the face layers
        for layer in sublayers as! [CALayer] {
            if (layer.name != nil && layer.name == "FaceLayer") {
                layer.isHidden = true
            }
        }
        
        if ( features.count == 0) {
            CATransaction.commit()
            return
        }
        
        let parentFrameSize : CGSize = previewView!.frame.size
        let gravity : NSString = previewLayer!.videoGravity as NSString
        
        let previewBox : CGRect = self.videoPreviewBoxForGravity(gravity: gravity, frameSize: parentFrameSize, apertureSize: clap.size)
        
        for ff in features as! [CIFaceFeature] {
            // set text on label
//            var x : CGFloat = 0.0, y : CGFloat = 0.0
//            if ff.hasLeftEyePosition {
//                x = ff.leftEyePosition.x
//                y = ff.leftEyePosition.y
//                //                eyeLeftLabel.text = ff.leftEyeClosed ? "(\(x) \(y))" : "(\(x) \(y))" + "👀"
//                eyeLeftLabel.text = ff.leftEyeClosed ? "" : "👀"
//            }
//            
//            if ff.hasRightEyePosition {
//                x = ff.rightEyePosition.x
//                y = ff.rightEyePosition.y
//                //                eyeRightLabel.text = ff.rightEyeClosed ? "(\(x) \(y))" : "(\(x) \(y))" + "👀"
//                eyeRightLabel.text = ff.rightEyeClosed ? "" : "👀"
//            }
//            
//            if ff.hasMouthPosition {
//                x = ff.mouthPosition.x
//                y = ff.mouthPosition.y
//                //                mouthLabel.text = ff.hasSmile ? "\(x) \(y)" + "😊" : "(\(x) \(y))"
//                mouthLabel.text = ff.hasSmile ? "😊" : ""
//            }
            
            // find the correct position for the square layer within the previewLayer
            // the feature box originates in the bottom left of the video frame.
            // (Bottom right if mirroring is turned on)
            var faceRect : CGRect = ff.bounds
            
            // flip preview width and height
            var temp : CGFloat = faceRect.width
            faceRect.size.width = faceRect.height
            faceRect.size.height = temp
            temp = faceRect.origin.x
            faceRect.origin.x = faceRect.origin.y
            faceRect.origin.y = temp
            // scale coordinates so they fit in the preview box, which may be scaled
            let widthScaleBy = previewBox.size.width / clap.size.height
            let heightScaleBy = previewBox.size.height / clap.size.width
            faceRect.size.width *= widthScaleBy
            faceRect.size.height *= heightScaleBy
            faceRect.origin.x *= widthScaleBy
            faceRect.origin.y *= heightScaleBy
            
            faceRect = faceRect.offsetBy(dx: previewBox.origin.x, dy: previewBox.origin.y)
            var featureLayer : CALayer? = nil
            // re-use an existing layer if possible
            while (featureLayer == nil) && (currentSublayer < sublayersCount) {
                
                let currentLayer : CALayer = sublayers.object(at: currentSublayer) as! CALayer
                currentSublayer += 1;
                if currentLayer.name == nil {
                    continue
                }
                let name : NSString = currentLayer.name! as NSString
                if name.isEqual(to: "FaceLayer") {
                    featureLayer = currentLayer;
                    currentLayer.isHidden = false
                }
            }
            
            // create a new one if necessary
            if featureLayer == nil {
                featureLayer = CALayer()
//                featureLayer?.contents = square.CGImage
                featureLayer?.name = "FaceLayer"
                previewLayer?.addSublayer(featureLayer!)
            }
            
            featureLayer?.frame = faceRect
            
            currentFeature += 1
        }
        
        CATransaction.commit()
    }
    
    func videoPreviewBoxForGravity(gravity : NSString, frameSize : CGSize, apertureSize : CGSize) -> CGRect {
        let apertureRatio : CGFloat = apertureSize.height / apertureSize.width
        let viewRatio : CGFloat = frameSize.width / frameSize.height
        
        var size : CGSize = CGSize.zero
        if gravity.isEqual(to: AVLayerVideoGravity.resizeAspectFill.rawValue) {
            if viewRatio > apertureRatio {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            } else {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            }
        } else if gravity.isEqual(to: AVLayerVideoGravity.resizeAspect.rawValue) {
            if viewRatio > apertureRatio {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            } else {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            }
        } else if gravity.isEqual(to: AVLayerVideoGravity.resize.rawValue) {
            size.width = frameSize.width
            size.height = frameSize.height
        }
        
        var videoBox : CGRect = CGRect.zero
        videoBox.size = size
        if size.width < frameSize.width {
            videoBox.origin.x = (frameSize.width - size.width) / 2;
        } else {
            videoBox.origin.x = (size.width - frameSize.width) / 2;
        }
        
        if size.height < frameSize.height {
            videoBox.origin.y = (frameSize.height - size.height) / 2;
        } else {
            videoBox.origin.y = (size.height - frameSize.height) / 2;
        }
        
        return videoBox
    }
    
    
}

    
//    func startDetection() {
//        self.setupAVCapture()
//        self.videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
//        var detectorOptions: [AnyHashable: Any] = [CIDetectorAccuracy: CIDetectorAccuracyLow]
//        self.faceDetector = CIDetector.ofType(CIDetectorTypeFace, context: nil, options: detectorOptions)
//    }
//    
//    func stopDetection() {
//        self.teardownAVCapture()
//    }
//    // clean up capture setup
//    
//    func teardownAVCapture() {
//        if self.videoDataOutputQueue {
//            self.videoDataOutputQueue = nil
//        }
//    }
//    protocol DetectFaceDelegate: class {
//        func detectedFaceController(_ controller: DetectFace, features featuresArray: [Any], forVideoBox clap: CGRect, withPreviewBox previewBox: CGRect)
//    }






