//
//  VideoLauncher.swift
//  YourAds PoC
//
//  Created by Cris Toozs on 27/02/2017.
//  Copyright © 2017 Cris Toozs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    var player: AVPlayer?
    var isPlaying = false
    
    // constructor/initialisation
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        playVideo()

        controlsContainerView.frame = self.bounds
        addSubview(controlsContainerView)
        
        controlsContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        controlsContainerView.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        backgroundColor = .black
        
    }
    
    // play/pause button handler
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "pause")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = true
        
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        
        return button
    }()
    
    func handlePause ()
    {
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
            pausePlayButton.tintColor = .white
        } else {
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
            pausePlayButton.tintColor = .clear
        }
        
        isPlaying = !isPlaying
    }
    
    // loading animation handler
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return (aiv)
    }()
    
    // Video controls overlay container
    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white:0, alpha: 1)
        return view
    }()
    
    
    // Setup video containers and play video in view
    private func playVideo() {
        
        
        let videoURL: NSURL = Bundle.main.url(forResource: "SampleVideo_1280x720_1mb", withExtension: "mp4")! as NSURL
        
        
        
        player = AVPlayer(url: videoURL as URL)
        
        let playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer)
        playerLayer.frame = self.bounds
        player?.play()

        
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                self.player?.seek(to: kCMTimeZero)
                self.player?.play()
            }
        })
    }
    
    // Checker for seeing if video is ready to render
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clear
            pausePlayButton.isHidden = false
            pausePlayButton.tintColor = .clear
            isPlaying = true
        }
    }
    
    // ignoring an error
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VideoLauncher: NSObject {
    
    // sets up the view with the correct frame and sets as current view
    func showVideoPlayer() {
        
        if let keyWindow = UIApplication.shared.keyWindow {
            print("567")
            let view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.black
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            
            let height = keyWindow.frame.width * 9 / 16
            let videoPlayerFrame = CGRect(x:0, y: (keyWindow.frame.height / 2) - (height / 2), width: keyWindow.frame.width, height: height)
            let videoPlayerView = VideoPlayerView(frame: videoPlayerFrame)
            view.addSubview(videoPlayerView)
            
            keyWindow.addSubview(view)
            view.frame = keyWindow.frame

//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//                
//                view.frame = keyWindow.frame
//            
//            }, completion: { (completedAnimation) in
//                UIApplication.shared.setStatusBarHidden(true, with: .fade)
//                
//            })
        }
        
    }
}
