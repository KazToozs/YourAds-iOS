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
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet var homeCollectionView: UICollectionView!
    let yourAdsHelper: YourAdsHelper
    var videoJSONArray: [NSDictionary]?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        yourAdsHelper = YourAdsHelper()
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

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let value = videoJSONArray?.count ?? 0
        if (value <= 0) {
            // Action when no videos are found
            print ("No videos found")
        }
        return value
    }
    
    // Definition of the cells that populate the view for each item counted above in numberOfItemsInSection
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdCollectionViewCell", for: indexPath)
        
        
        return cell
    }
    
    private func loadVideoListFromServer() {
        //        var token = "Bearer JGYMkqcLBLjE9hGvmuqfjlgVgph8IO6uQkDK7hgYRYvNRTx7PgVC9kmUVQJPY5wdP3qECpNJiOWq4UsyJ41RLCYLojvhP8hS1yDqeyQNPCbqpo2tcxll4wKswnToQeio1totg0Xk9y2rPLRUEQvGg3LH1llVV449UtA9ole5Kp26HNFnkenXN4niDqucxBN06u9ssFlPEajVRukKmYAMemXplEq2eByvyxdREtM9dNTRt8crvHvDHaX4TaimQhEc"
        
        guard let url = URL(string: yourAdsHelper.serverAddress + "/api/video/listAvailableVideo") else
        {
            return
        }
        Alamofire.request(url,
                          method: .get,
                          headers: ["PhoneIdentifiers" : yourAdsHelper.advertisingId, "type" : "iOS"])
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
                        
                        videoJSONArray?.append(contentsOf: JSON)
                        print(JSON)
                    }
                }
                self.collectionView?.reloadData()
        }
    }
}

