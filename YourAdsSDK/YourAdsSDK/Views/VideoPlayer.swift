//
//  VideoPlayer.swift
//  YourAdsSDK
//
//  Created by Cris Toozs on 25/10/2018.
//

import UIKit
import AVFoundation

public class VideoPlayer: UIView {
    var player: AVPlayer?
    public var isPlaying = false
    public var timeSkipped: CMTime?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc public func handlePause ()
    {
        if isPlaying {
            player?.pause()
            //            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
            //            pausePlayButton.tintColor = .white
        } else {
            player?.play()
            //            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
            //            pausePlayButton.tintColor = .clear
        }
        
        isPlaying = !isPlaying
    }
    
    public func addBackButtonBoundaryTimeObserver(button: UIButton) {
        let backButtonTimer = CMTime(seconds: 5.0, preferredTimescale: 1)
        var times = [NSValue]()
        
        times.append(NSValue(time: backButtonTimer))

        player!.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            button.isHidden = false
            button.isEnabled = true
        }
    }
    
    public func setVideoForPlayback(url: URL) {
        player = AVPlayer(url: url)
    }
    
    public func addEndTimeObserver(controller: YourAdsController) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                let skipped = false
                let nbPauses = controller.cameraRecorder!.nbPauses
                let videoId = controller.advertId!
                let phoneId = controller.yourAdsHelper!.phoneId
                let modelName = controller.yourAdsHelper!.modelName
                let attention = controller.cameraRecorder!.attention
                let timeZone = controller.yourAdsHelper!.timeZone
//                var videoItem = self.player?.currentItem
//                var timeSkipped = videoItem?.currentTime()
                controller.yourAdsHelper!.sendStats(skipped: skipped, skippedTime: 0, videoId: videoId, phoneId: phoneId, timeZone: timeZone, modelName: modelName, attention: attention)
                
                controller.returnToPreviousStoryboard()
            }
        })
    }
    
    public func playVideo() {
        //        let videoURL: NSURL = Bundle.main.url(forResource: "SampleVideo_1280x720_1mb", withExtension: "mp4")! as NSURL
        
//        let videoUrl = NSURL(string: videoHelper.serverAddress + "/api/video/file/"  + videoHelper.videoId! + "/" + videoHelper.videoFilename!);
        
        //let escapedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)
        
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
//        player?.play()
        // reset to start at end of video
        //player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
    }
    
    // ignoring an error
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
