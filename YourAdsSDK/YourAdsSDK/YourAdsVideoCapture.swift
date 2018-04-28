//
//  VideoCapture.swift
//  CameraFacetrackTest
//
//  Created by Cris Toozs on 19/11/2017.
//  Copyright © 2017 Cris Toozs. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation

public class YourAdsVideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var isCapturing: Bool = false
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var input: AVCaptureInput?
    var preview: CALayer?
    var faceDetector: FaceDetector?
    var dataOutput: AVCaptureVideoDataOutput?
    var dataOutputQueue: DispatchQueue?
//    var previewView: UIView?
    var previewView: UIImageView?
    
    // To be used as the Cv Camera delegate since Swift cannot support it
    var videoCameraWrapper : CvVideoCameraWrapper!
    
    enum VideoCaptureError: Error {
        case SessionPresetNotAvailable
        case InputDeviceNotAvailable
        case InputCouldNotBeAddedToSession
        case DataOutputCouldNotBeAddedToSession
    }
    
    public override init() {
        super.init()
        
        device = VideoCaptureDevice.create()
        faceDetector = FaceDetector()
    }
    
    public func startCapturing(previewView: UIImageView) throws {
        isCapturing = true
        
        self.previewView = previewView

        self.videoCameraWrapper = CvVideoCameraWrapper(videoCapture:self, andImageView:previewView)

        try setSessionPreset()
        
        try setDeviceInput()
        
        try addInputToSession()
        
        setDataOutput()
        
        try addDataOutputToSession()
        
        addPreviewToView(view: self.previewView!)
        
        session!.startRunning()
    }
    
    private func addPreviewToView(view: UIView) {
        self.preview = AVCaptureVideoPreviewLayer(session: session!)
        self.preview!.frame = view.bounds
        
        view.layer.addSublayer(self.preview!)
    }
    
    private func setSessionPreset() throws {
        self.session = AVCaptureSession()

        if (session!.canSetSessionPreset(AVCaptureSession.Preset.vga640x480)) {
            session!.sessionPreset = AVCaptureSession.Preset.vga640x480
        }
        else {
            throw VideoCaptureError.SessionPresetNotAvailable
        }
    }
    
    
    private func addDataOutputToSession() throws {
        if (self.session!.canAddOutput(self.dataOutput!)) {
            self.session!.addOutput(self.dataOutput!)
        }
        else {
            throw VideoCaptureError.DataOutputCouldNotBeAddedToSession
        }
    }
    
    private func setDeviceInput() throws {
        do {
//            self.input = try AVCaptureDeviceInput(device: self.device!.devices.first!)
            self.input = try AVCaptureDeviceInput(device: self.device!)
        }
        catch {
            throw VideoCaptureError.InputDeviceNotAvailable
        }
    }
    
    private func addInputToSession() throws {
        if (session!.canAddInput(self.input!)) {
            session!.addInput(self.input!)
        }
        else {
            throw VideoCaptureError.InputCouldNotBeAddedToSession
        }
    }
    
    private func setDataOutput() {
        self.dataOutput = AVCaptureVideoDataOutput()
        
        var videoSettings = [NSObject : AnyObject]()
        videoSettings[kCVPixelBufferPixelFormatTypeKey] = Int(CInt(kCVPixelFormatType_32BGRA)) as AnyObject
        
        self.dataOutput!.videoSettings = videoSettings as! [String : Any]
        self.dataOutput!.alwaysDiscardsLateVideoFrames = true
        
        self.dataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        
        self.dataOutput!.setSampleBufferDelegate(self, queue: self.dataOutputQueue!)
    }
    
    
    class VideoCaptureDevice {
        
//        static func create() -> AVCaptureDevice.DiscoverySession {
//            let device = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
//
//            return device
//            
//        }

/*
**     Commented code here is functional code from Swift 2 - 3
*/
    static func create() -> AVCaptureDevice {
                    var device: AVCaptureDevice?

                    AVCaptureDevice.devices(for: AVMediaType.video).forEach { videoDevice in
                        if ((videoDevice as AnyObject).position == AVCaptureDevice.Position.front) {
                            device = videoDevice as AVCaptureDevice
                        }
                    }

                    if (nil == device) {
                        device = AVCaptureDevice.default(for: .video)
                    }

                    return device!
    }
        
        
    }
    
 public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let image = getImageFromBuffer(buffer: sampleBuffer)
    
        let features = getFacialFeaturesFromImage(image: image)
        
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(formatDescription!, false)
        
        DispatchQueue.main.async() {
            self.alterPreview(features: features, cleanAperture: cleanAperture)
        }
    }
    
    private func getImageFromBuffer(buffer: CMSampleBuffer) -> CIImage {
        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, buffer, kCMAttachmentMode_ShouldPropagate)
        
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!, options: attachments as? [String : Any])
        
        return cameraImage
    }
    
    private func getFacialFeaturesFromImage(image: CIImage) -> [CIFeature] {
        let imageOptions = [CIDetectorImageOrientation : 6]
        
        return self.faceDetector!.getFacialFeaturesFromImage(image: image, options: imageOptions as [String : AnyObject])
        
    }
    
    private func alterPreview(features: [CIFeature], cleanAperture: CGRect) {
        removeFeatureViews()
        
        if (features.count == 0 || cleanAperture == CGRect.zero) {
            return
        }
        
        for feature in features {
            let faceFeature = feature as? CIFaceFeature
            
            if (faceFeature!.hasLeftEyePosition) {
                
                addEyeViewToPreview(xPosition: faceFeature!.leftEyePosition.x,
                                    yPosition: faceFeature!.leftEyePosition.y, cleanAperture: cleanAperture)
            }
            
            if (faceFeature!.hasRightEyePosition) {
                
                addEyeViewToPreview(xPosition: faceFeature!.rightEyePosition.x,
                                    yPosition: faceFeature!.rightEyePosition.y, cleanAperture: cleanAperture)
            }
        }
    }
    
    private func removeFeatureViews() {
        if let pv = previewView {
            for view in pv.subviews {
                if (view.tag == 1001) {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    private func getFeatureView() -> UIView {
        let heartView = Bundle.main.loadNibNamed("HeartView", owner: self, options: nil)?[0] as! UIView
        heartView.backgroundColor = UIColor.clear
        heartView.layer.removeAllAnimations()
        heartView.tag = 1001
        
        return heartView
    }
    
    private func transformFacialFeaturePosition(xPosition: CGFloat, yPosition: CGFloat,
                                                videoRect: CGRect, previewRect: CGRect, isMirrored: Bool) -> CGRect {
        
        var featureRect = CGRect(origin: CGPoint(x: xPosition, y: yPosition),
                                 size: CGSize(width: 0, height: 0))
        let widthScale = previewRect.size.width / videoRect.size.height
        let heightScale = previewRect.size.height / videoRect.size.width
        
        var transform: CGAffineTransform
        if (isMirrored) {
            transform = CGAffineTransform(a: 0, b: heightScale, c: -widthScale, d: 0, tx: previewRect.size.width, ty: 0)
        }
        else {
            transform = CGAffineTransform(a: 0, b: heightScale, c: widthScale, d: 0, tx: 0, ty: 0)
        }
        
        featureRect = featureRect.applying(transform)
        
        featureRect = featureRect.offsetBy(dx: previewRect.origin.x, dy: previewRect.origin.y)
        
        return featureRect
    }
    
    private func addEyeViewToPreview(xPosition: CGFloat, yPosition: CGFloat, cleanAperture: CGRect) {
        let eyeView = getFeatureView()
        let isMirrored = preview!.contentsAreFlipped()
        let previewBox = preview!.frame
                
        previewView!.addSubview(eyeView)
        
        var eyeFrame = transformFacialFeaturePosition(xPosition: xPosition, yPosition: yPosition,
                                                      videoRect: cleanAperture, previewRect: previewBox, isMirrored: isMirrored)
        
        eyeFrame.origin.x -= 37
        eyeFrame.origin.y -= 37
        
        eyeView.frame = eyeFrame
    }
    
    
    
    class FaceDetector {
        var detector: CIDetector?
        var options: [String : AnyObject]?
        var context: CIContext?
        
        init() {
            context = CIContext()
            
            options = [String : AnyObject]()
            options![CIDetectorAccuracy] = CIDetectorAccuracyLow as AnyObject
            
            detector = CIDetector(ofType: CIDetectorTypeFace, context: context!, options: options!)
        }
        
        func getFacialFeaturesFromImage(image: CIImage, options: [String : AnyObject]) -> [CIFeature] {
            return self.detector!.features(in: image, options: options)
        }
    }
    
}
