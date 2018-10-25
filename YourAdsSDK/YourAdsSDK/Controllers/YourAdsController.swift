//
//  ViewController.swift
//  YourAdsSDK
//
//  Created by Cris Toozs on 28/09/2018.
//

import UIKit
import Foundation

public class YourAdsController: UIViewController {
    @IBOutlet weak var videoPlayerView: VideoPlayer!
    @IBOutlet weak var cameraRecorderView: UIView!
    public var yourAdsHelper: YourAdsHelper?
    private var cameraRecorder: CameraRecorder?
    public var advertisementId: Int?
    public var advertisementFilename: String?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        cameraRecorder = CameraRecorder(videoToMonitor: videoPlayerView)
        // Do any additional setup after loading the view.
        launchYourAdsAdvertisement()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

//    public func launchYourAdsAdvertisement(viewController: UIViewController, videoCapturer: VideoCapture) {
//        let videoLauncher = VideoLauncher()
//        let myView = UIView()
//        
//        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//        
//        videoLauncher.showVideoPlayer(videoHelper: self)
//        videoCapturer.setVideoPlayerView(videoPlayerView: videoLauncher.videoPlayerView!)
//        
//        if let keyWindow = UIApplication.shared.keyWindow {
//            
//            myView.frame = CGRect(x: keyWindow.frame.width / 2 - (keyWindow.frame.width / 3 / 2),
//                                  y: 0,
//                                  width: keyWindow.frame.width / 3,
//                                  height: keyWindow.frame.height / 3)
//            
//            keyWindow.addSubview(myView)
//            
//            viewController.view = UIApplication.shared.keyWindow
//            do {
//                try videoCapturer.startCapturing(previewView: myView)
//            }
//            catch {
//            }
//        }
//    }
    
    public func launchYourAdsAdvertisement()
    {
        var url = URL(string: "http://yourads.ovh")
        url = url?.appendingPathComponent("/api/video/file/" + String(advertisementId!) + "/" + advertisementFilename!)
        
        videoPlayerView.playVideo(url: url!)
        do {
            try cameraRecorder?.startCapturing(previewView: cameraRecorderView)
        }
        catch {
            print("problem")
        }
        
    }
    
}
