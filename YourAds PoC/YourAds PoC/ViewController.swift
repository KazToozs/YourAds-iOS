//
//  ViewController.swift
//  YourAds PoC
//
//  Created by Cris Toozs on 22/02/2017.
//  Copyright © 2017 Cris Toozs. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var openCVVersionLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var camera: AVCaptureDevice?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let videoLauncher = VideoLauncher()
        let cameraLauncher = CameraLauncher()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
                
        videoLauncher.showVideoPlayer()
        cameraLauncher.showCamera()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    
}

