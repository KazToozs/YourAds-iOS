//
//  YourAdsHelper.swift
//  YourAdsSDK
//
//  Created by Cris Toozs on 20/10/18.
//

import Foundation
import AdSupport
import Alamofire

public class YourAdsHelper {
    
    public var advertisingId : String
    public let serverAddress = "http://yourads.ovh"
    // Recovered video information
    public var videoId : String?
    public var videoFilename : String?
    public var videoImgUri : String?
    
    /*
     ** Data structure for sending to the server
     */
    
    private class videoRecordStats {
        private var nbPauses : Int
        private var phoneId : String
        private var videoId : Int
        private var skippedTime : Int
        private var skipped : Bool
        
        private init(nbPauses: Int, phoneId: String, videoId: Int, skippedTime: Int, skipped: Bool) {
            self.nbPauses = nbPauses
            self.phoneId = phoneId
            self.videoId = videoId
            self.skipped = skipped
            self.skippedTime = skippedTime
        }
    }
    
    public init() {
        advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString.lowercased()
        if (advertisingId == "00000000-0000-0000-0000-000000000000")
        {
            advertisingId = NSUUID().uuidString.lowercased()
        }
        print("Advertising Id: " + advertisingId)
    }
    
    // load videos from the server
    private func loadVideoIdFromServer() {
        //        var token = "Bearer JGYMkqcLBLjE9hGvmuqfjlgVgph8IO6uQkDK7hgYRYvNRTx7PgVC9kmUVQJPY5wdP3qECpNJiOWq4UsyJ41RLCYLojvhP8hS1yDqeyQNPCbqpo2tcxll4wKswnToQeio1totg0Xk9y2rPLRUEQvGg3LH1llVV449UtA9ole5Kp26HNFnkenXN4niDqucxBN06u9ssFlPEajVRukKmYAMemXplEq2eByvyxdREtM9dNTRt8crvHvDHaX4TaimQhEc"
        
        guard let url = URL(string: serverAddress + "/api/video/getLink") else
        {
            return
        }
        Alamofire.request(url, method: .get, headers: ["PhoneIdentifiers" : advertisingId, "type" : "iOS"])
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
                    if let results = response.result.value {
                        let JSON = results as! NSDictionary
                            
                            self.videoId = String(JSON.object(forKey: "id") as! Int64)
                            self.videoFilename = JSON.object(forKey: "filename") as? String
                            self.videoImgUri = JSON.object(forKey: "thumbnailfilename") as? String
                            print(JSON)
                    }
                    
                }
    }

}
