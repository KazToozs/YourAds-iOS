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
        
    public func playVideo(url: URL) {
        //        let videoURL: NSURL = Bundle.main.url(forResource: "SampleVideo_1280x720_1mb", withExtension: "mp4")! as NSURL
        
//        let videoUrl = NSURL(string: videoHelper.serverAddress + "/api/video/file/"  + videoHelper.videoId! + "/" + videoHelper.videoFilename!);
        
        //let escapedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)
        
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        player?.play()
        
        // reset to start at end of video
        //player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil, using: { (_) in
//            DispatchQueue.main.async {
//                self.player?.seek(to: kCMTimeZero)
//                self.player?.play()
//            }
//        })
    }
    
    // ignoring an error
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
