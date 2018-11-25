//
//  CameraRecorder.swift
//  YourAdsSDK
//
//  Created by Cris Toozs on 25/10/2018.
//

import Foundation
import AVKit
import AVFoundation

/*
 ** VideoCapture sets up the camera run session and structures the modification of it's output
 ** Subclass VideoCaptureDevice is the 'device' that handles the live monitoring of the camera output
 ** Subclass FaceDetector collects facial features from the image provided and returns them
 */
public class CameraRecorder: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var isCapturing: Bool = false
    var isWatching: Bool = false
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var input: AVCaptureInput?
    var faceDetector: FaceDetector?
    var dataOutput: AVCaptureVideoDataOutput?
    var dataOutputQueue: DispatchQueue?
    var videoToMonitor: VideoPlayer?
    
    var nbPauses: Int = 0
    var skipped: Bool = false
    var skippedTime: CMTime?
    var maxFaces = 0
    var attention: [Attention] = []
    
    var faceFeatureCount = 0
    
    
    enum VideoCaptureError: Error {
        case SessionPresetNotAvailable
        case InputDeviceNotAvailable
        case InputCouldNotBeAddedToSession
        case DataOutputCouldNotBeAddedToSession
    }
    
    public init(videoToMonitor: VideoPlayer) {
        super.init()
        
        self.videoToMonitor = videoToMonitor
        device = VideoCaptureDevice.create()
        faceDetector = FaceDetector()
    }
    
    /*
     ** Sets the live camera display to the given UIView with live face detection
     */
    public func startCapturing() throws {
        isCapturing = true
        
        
        // setup the device for frontal camera live capture and output
        self.session = AVCaptureSession()
        try setSessionPreset()
        try setDeviceInput()
        try addInputToSession()
        setDataOutput()
        try addDataOutputToSession()
        
        // set camera output to given view and start running
        session!.startRunning()
    }
    
    private func setSessionPreset() throws {
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
    
    public func setVideoPlayerView(videoPlayerView: VideoPlayer) {
        self.videoToMonitor = videoPlayerView
    }
    
    private func setDeviceInput() throws {
        do {
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
        
        self.dataOutput!.videoSettings = (videoSettings as! [String : Any])
        self.dataOutput!.alwaysDiscardsLateVideoFrames = true
        
        self.dataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        
        self.dataOutput!.setSampleBufferDelegate(self, queue: self.dataOutputQueue!)
    }
    
    
    class VideoCaptureDevice {
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
    
    
    /*
     ** For each image caputred in the camera input, find facial features and alter the image
     */
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let image = getImageFromBuffer(buffer: sampleBuffer)
        let features = getFacialFeaturesFromImage(image: image)

        if (features.isEmpty) {
            if (faceFeatureCount > 0) {
//                videoToMonitor?.handlePause()
                let currentTime = (videoToMonitor?.player?.currentItem?.currentTime().seconds)! * 1000
                self.nbPauses += 1
                faceFeatureCount = 0
                print("--- changed to no faces ---")
                print("0")
                let changedAttention = Attention(attention: 0, timeStamp: Int64(currentTime))
                attention.append(changedAttention)
                isWatching = false
            }
        }
        else {
            var currentFaceFeatureCount = 0
            for feature in features {
                if ((feature as? CIFaceFeature) != nil) {
                    currentFaceFeatureCount += 1
                }
            }
            isWatching = true
            if (videoToMonitor?.isPlaying == false) {
                videoToMonitor?.handlePause()
                let currentTime = (videoToMonitor?.player?.currentItem?.currentTime().seconds)! * 1000
                let changedAttention = Attention(attention: currentFaceFeatureCount, timeStamp: Int64(currentTime))
                print("--- More faces (start) ---")
                print(currentFaceFeatureCount)
                attention.append(changedAttention)
            }
            else if (currentFaceFeatureCount != faceFeatureCount) {
                let currentTime = (videoToMonitor?.player?.currentItem?.currentTime().seconds)! * 1000
                let changedAttention = Attention(attention: currentFaceFeatureCount, timeStamp: Int64(currentTime))
                print("--- changed number of faces ---")
                print(currentFaceFeatureCount)
                attention.append(changedAttention)
            }
            faceFeatureCount = currentFaceFeatureCount
        }
    }
    
    public func getIsWatching() -> Bool {
        return isWatching
    }
    
    private func getImageFromBuffer(buffer: CMSampleBuffer) -> CIImage {
        let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: buffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!, options: convertToOptionalCIImageOptionDictionary(attachments as? [String : Any]))
        
        return cameraImage
    }
    
    
    private func getFacialFeaturesFromImage(image: CIImage) -> [CIFeature] {
        let imageOptions = [CIDetectorImageOrientation : 6]
        
        return self.faceDetector!.getFacialFeaturesFromImage(image: image, options: imageOptions as [String : AnyObject])
        
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
    
    class FaceDetector {
        var detector: CIDetector?
        var options: [String : AnyObject]?
        var context: CIContext?
        var maxFaces: Int = 0
        
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalCIImageOptionDictionary(_ input: [String: Any]?) -> [CIImageOption: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (CIImageOption(rawValue: key), value)})
}
