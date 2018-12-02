//
//  ViewController.swift
//  YourAdsPoC3.0
//
//  Created by Cris Toozs on 28/09/2018.
//  Copyright © 2018 Cris Toozs. All rights reserved.
//

import UIKit
import Alamofire
import YourAdsSDK

class HomeCollectionViewController: UICollectionViewController {

    @IBOutlet var homeCollectionView: UICollectionView!
    let yourAdsHelper: YourAdsHelper
    var videoJSONArray: [NSDictionary]
    var selectedIndex: Int?
   
    
    // ----- VIEW CONTROLLER METHODS -----
    
    required init?(coder aDecoder: NSCoder) {
        // set device orientation to portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        yourAdsHelper = YourAdsHelper()
        videoJSONArray = [NSDictionary]()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.homeCollectionView.register(UINib(nibName: "AdCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdCollectionViewCell")
        loadVideoListFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if let navVC = segue.destination as? UINavigationController  {
//        if let destinationViewController = navVC.viewControllers.first as? YourAdsController {

            if let destinationViewController = segue.destination as? YourAdsController {

                if (segue.identifier == "segueToPlayer") {
                    destinationViewController.yourAdsHelper = yourAdsHelper
                    destinationViewController.advertisementFilename = (videoJSONArray[selectedIndex!]["videoFilename"] as! String)
                    destinationViewController.advertId = (videoJSONArray[selectedIndex!]["id"] as! Int64)
                    destinationViewController.previousStoryboardName = "Main"
                    destinationViewController.previousControllerId = "HomeController"
                }
                else if (segue.identifier == "segueButton") {
                    destinationViewController.yourAdsHelper = yourAdsHelper
                    destinationViewController.previousStoryboardName = "Main"
                    destinationViewController.previousControllerId = "HomeController"
                }
            }
//        }
    }
    
    // ----- COLLECTION VIEW METHODS -----

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let value = self.videoJSONArray.count
        if (value <= 0) {
            // Action when no videos are found
            print ("No videos found")
        }
        return value
    }
    
    // Definition of the cells that populate the view for each item counted above in numberOfItemsInSection
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let thumbnail = videoJSONArray[indexPath.item]["thumbnailFilename"] as! String
        let id = videoJSONArray[indexPath.item]["id"] as! Int
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdCollectionViewCell", for: indexPath) as! AdCollectionViewCell
        
        cell.adName.text = (videoJSONArray[indexPath.item]["videoName"] as! String)
//        cell.thumbnailImage.downloaded(from: yourAdsHelper.serverAddress
//                                        + "/api/video/file/"
//                                        + String(id) + "/" + thumbnail)
        
        var url = URL(string: "http://yourads.ovh")
        url = url?.appendingPathComponent("/api/video/file/" + String(id) + "/" + thumbnail)
        cell.thumbnailImage.downloaded(from: url!)

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
            self.performSegue(withIdentifier: "segueToPlayer", sender: self)
    }
    
    
    // ----- PERSONAL METHODS -----
    
    private func loadVideoListFromServer() {
        guard let url = URL(string: yourAdsHelper.serverAddress + "/api/video/listAvailableVideo") else
        {
            return
        }
        
        let headers: HTTPHeaders = [
            "PhoneIdentifiers" : yourAdsHelper.phoneId,
            "type" : "iOS",
            "model" : yourAdsHelper.modelName
        ]
        
        self.videoJSONArray.removeAll()
        
        Alamofire.request(url,
                          headers: headers)
            .responseJSON { response in
                print(response)
                print("status: \(String(describing: response.response?.statusCode))")
                //to get status code
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        print("example success")
                    default:
                        print("error with response status: \(status)")
                    }
                }
                //to get JSON return value
                if let results = response.result.value as? [Any] {
                    for result in results {
                        let JSON = result as! NSDictionary
                        self.videoJSONArray.append(JSON)
                        print (self.videoJSONArray.count)
                    }
                }
                self.collectionView?.reloadData()
        }
        
    }
}

