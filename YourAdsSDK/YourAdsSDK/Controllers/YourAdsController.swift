//
//  ViewController.swift
//  YourAdsSDK
//
//  Created by Cris Toozs on 28/09/2018.
//

import UIKit
import Foundation

public class YourAdsController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var videoPlayerView: VideoPlayer!
    public var yourAdsHelper: YourAdsHelper?
    public var cameraRecorder: CameraRecorder?
    public var advertId: Int64?
    public var advertisementFilename: String?
    public var previousStoryboardName: String?
    public var previousControllerId: String?
    
    override public func loadView() {
        super.loadView()
        
//                if (advertId == nil || advertisementFilename == nil) {
//            yourAdsHelper?.loadRandomVideo(completion: { (videoId, videoFilename) in
//                if (videoId != nil && videoFilename != nil) {
//                    self.advertisementFilename = videoFilename
//                    self.advertId = Int64(videoId!)
//                    self.launchYourAdsAdvertisement()
//                }
//                else {
//                    print("Random video load returns a nil value")
//                }
//            })
//        }
//                else {
//                    self.launchYourAdsAdvertisement()
//        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        cameraRecorder = CameraRecorder(videoToMonitor: videoPlayerView)
        // Do any additional setup after loading the view.
        if (advertId == nil || advertisementFilename == nil) {
            yourAdsHelper?.loadRandomVideo(completion: { (videoId, videoFilename) in
                if (videoId != nil && videoFilename != nil) {
                    let number: Int64? = Int64(videoId!)
                    self.advertisementFilename = videoFilename
                    self.advertId = number
                    self.launchYourAdsAdvertisement()
                }
                else {
                    print("Random video load returns a nil value")

                }
            })
        }
        else {
            self.launchYourAdsAdvertisement()
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        cameraRecorder?.input = nil
            cameraRecorder?.device = nil
            cameraRecorder?.session = nil
            cameraRecorder?.dataOutput = nil
        cameraRecorder?.dataOutputQueue = nil
        cameraRecorder?.videoToMonitor = nil
        cameraRecorder = nil
        if (videoPlayerView.player != nil) {
            videoPlayerView.player?.replaceCurrentItem(with: nil)
            videoPlayerView.player = nil
        }
        advertId = nil
        advertisementFilename = nil
    }

    @objc func backButtonAction() {
        let skipped = true
        let videoId = advertId!
        let videoItem = videoPlayerView.player?.currentItem
        let timeSkipped = Int64((videoItem?.currentTime().seconds)! * 1000)
        let phoneId = yourAdsHelper!.phoneId
        
        let attention = cameraRecorder!.attention
        let modelName = yourAdsHelper?.modelName
        let timeZone = yourAdsHelper!.timeZone

        
        
        yourAdsHelper?.sendStats(skipped: skipped, skippedTime: timeSkipped, videoId: videoId, phoneId: phoneId, timeZone: timeZone, modelName: modelName!, attention: attention)
        returnToPreviousStoryboard()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func returnToPreviousStoryboard() {
//        let storyboard = UIStoryboard(name: self.previousStoryboardName!, bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: self.previousControllerId!) as! UICollectionViewController
//        self.present(vc, animated: true, completion: nil)
//
//        self.navigationController?
//            .popViewController(animated: true)
        
        self.dismiss(animated: true, completion: nil)
    }
      
    public func launchYourAdsAdvertisement()
    {
        var url = URL(string: "http://yourads.ovh")
        url = url?.appendingPathComponent("/api/video/file/" + String(advertId!) + "/" + advertisementFilename!)
        
        videoPlayerView.setVideoForPlayback(url: url!)
        videoPlayerView.addBackButtonBoundaryTimeObserver(button: backButton)
        videoPlayerView.addEndTimeObserver(controller: self)
        videoPlayerView.playVideo()
        do {
            try cameraRecorder?.startCapturing()
        }
        catch {
            print("problem")
        }
        
    }
    
}
