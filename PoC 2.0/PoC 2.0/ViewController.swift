//
//  ViewController.swift
//  PoC 2.0
//
//  Created by Cris Toozs on 04/06/2017.
//  Copyright © 2017 Cris Toozs. All rights reserved.
//

import UIKit
import YourAdsSDK

/*
// UICollectionViewController: view controller with a collection view in it
// UICollectionViewDelegateFlowLayout: allows sizing of elements within grid based layout of UICollectionViewFlowLayout
*/
 class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var videoCapture: YourAdsVideoCapture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.title = "Home"
        
        collectionView?.backgroundColor = UIColor.white
        
        
        // registers the cells for the specified Cell identifier and turns them into the given object type
        collectionView?.register(VideoCell.self, forCellWithReuseIdentifier: "cellId")
    }

    // On view appear, lock orientation to portrait
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
    }

    // Reset ability to change orientation when leaving the ViewController
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.all)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Number of items in the CollectionView (I think)
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    // Definition of the cells that populate the view for each item counted above in numberOfItemsInSection
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        
        
        return cell
    }
    
    // Set dimensions for a cell within the CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    // Set spacing between cells, here we eliminate any extra spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoLauncher = VideoLauncher()
        let myView = UIView()
//        let cameraLauncher = CameraLauncher()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        videoLauncher.showVideoPlayer()

        if let keyWindow = UIApplication.shared.keyWindow {

            videoCapture = YourAdsVideoCapture()
            myView.frame = CGRect(x: keyWindow.frame.width / 2 - (keyWindow.frame.width / 3 / 2),
                                  y: 0,
                                  width: keyWindow.frame.width / 3,
                                  height: keyWindow.frame.height / 3)

            keyWindow.addSubview(myView)

        
            self.view = UIApplication.shared.keyWindow
            do {
                try videoCapture?.startCapturing(previewView: myView)
            }
            catch {
            }
        }
    
//        cameraLauncher.showCamera()

    }
    
}

// Cell for a video
class VideoCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    // setting a thumbnail image variable to the return of a function that creates a UIImage
    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.blue
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.purple
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = OpenCVWrapper.openCVVersionString()
        return label
    }()
    
    let subtitleTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.red
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // creating the separator between cells with a function
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    let moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "more_vert_grey_192x192"), for: UIControlState.normal)
        button.backgroundColor = UIColor.green
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /* 
    // sets cell parameters: sublayer dimensions, thumbnail image...
    // addConstraint adds padding
    // -> H:|-16-[v0]-16-| on the horizontal axis, 16 to the left, 16 pixels to the right, and the view spanning the gap
    // [v0(1)]| view of 1 pixel in height, touching bottom edge
    */
    func setupViews() {
        addSubview(thumbnailImageView)
        addSubview(separatorView)
        addSubview(titleLabel)
        addSubview(subtitleTextView)
        addSubview(moreButton)
        
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: thumbnailImageView)
        
        addConstraintsWithFormat(format: "H:[v0(44)]-16-|", views: moreButton)
        
        addConstraintsWithFormat(format: "V:|-16-[v0]-8-[v1(48)]-16-[v2(1)]|", views: thumbnailImageView, moreButton, separatorView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: separatorView)

        // top title constraint: the top of the titleLabel cannot go past the bottom of teh thumbnail with a margin of 8 pixels
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: thumbnailImageView, attribute: .bottom, multiplier: 1, constant: 8))
        // left title constraint: constrained to the same distance as the left side of the thumbnail
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: thumbnailImageView, attribute: .left, multiplier: 1, constant: 0))
        // right title constraint
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: moreButton, attribute: .left, multiplier: 1, constant: -8))
        // title height constraint
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20))

    
        // top subtitle constraint
        addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 8))
        // left subtitle constraint
        addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: .left, relatedBy: .equal, toItem: thumbnailImageView, attribute: .left, multiplier: 1, constant: 0))
        // right subtitle constraint
        addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: .right, relatedBy: .equal, toItem: moreButton, attribute: .left, multiplier: 1, constant: -8))
        // subtitle height constraint
        addConstraint(NSLayoutConstraint(item: subtitleTextView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/*
// Extension allows to add elements to an existing class
// Here we add a function to make the 'addContraints' function for UI manipulation more readable and generalised
*/
extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        // sets all views given in parameter in a dictionary with corresponding "v[id number]" string as key 
        // translateAutoResizingMaskIntoConstraints allows manual constraint modification
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
