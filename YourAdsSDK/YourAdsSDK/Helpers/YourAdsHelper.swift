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
    public var phoneId : String
    public let serverAddress = "http://yourads.ovh"
    // Recovered video information
    public var videoId : String?
    public var timeZone : String
    public let modelName = UIDevice.modelName
    public var videoFilename : String?
    public var videoImgUri : String?
    
    
    public init() {
        phoneId = ASIdentifierManager.shared().advertisingIdentifier.uuidString.lowercased()
        timeZone = TimeZone.current.abbreviation()!
        if (phoneId == "00000000-0000-0000-0000-000000000000")
        {
            phoneId = NSUUID().uuidString.lowercased()
        }
        print("Advertising Id: " + phoneId)
    }
    
//    public func sendStats(skipped: Bool, skippedTime: Int64,
//                          videoId: Int64, phoneId: String,
//                          timeZone: String, attention: [Attention]) {
//        let data = VideoRecordStats(skipped: skipped, skippedTime: skippedTime,
//                                    videoId: videoId, phoneId: phoneId,
//                                    timeZone: timeZone, attention: attention)
//
//        guard let url = URL(string: serverAddress + "/api/video/results") else
//        {
//            return
//        }
//        let headers = ["PhoneIdentifiers" : phoneId, "type" : "iOS"]
//        var jsonData: [String : Any]?
//        jsonData = dataToJson(data: data)
//        print(jsonData)
//        Alamofire.request(url, method: .post,
//                          parameters: jsonData)
//                do {
//                    let jsonData = try JSONEncoder().encode(data)
//                    let stringData = String(data: jsonData, encoding: .utf8)
//                    print("JSON DATA: ")
//                    print(stringData)
//                } catch {
//                    print(error)
//                }
//    }
    
        public func sendStats(skipped: Bool, skippedTime: Int64,
                              videoId: Int64, phoneId: String, modelName: String, attention: [Attention]) {
            let data = VideoRecordStats(skipped: skipped, skippedTime: skippedTime,
                                        videoId: videoId, phoneId: phoneId,
                                        timeZone: timeZone, modelName: modelName, attention: attention)
    
            //        let headers = ["PhoneIdentifiers" : phoneId, "type" : "iOS"]
            //        var jsonData: [String : Any]?
            //        jsonData = dataToJson(data: data)
    
            let urlString = serverAddress + "/api/video/results"
            let jsonEncoder = JSONEncoder()
            let url = URL(string: urlString)!
            var jsonData: Data?
            do { jsonData = try jsonEncoder.encode(data) }
            catch { }
            var request = URLRequest(url: url)
    
            let token = "FfFqy22U4Psy3XkfDMcW8YJq2JsFduHlUxdgSQzQJpkfeb1Xw9Uz834ssKzdDK9Kd46s7TVF1yTbqs01rsX6OVumzUdzXzNfdtfaDxb9rosU5nM9ezbWQq6dCElQpsWPW3DupRsqpSng8b0IUiBUveJvBfSRXaeHxGTIAh6ZWNYpiCKG4ZAz3cWApsRyoTinjWHQM5rYQZRbaOTCA0r1yHI6hb82QK469KUWDnY8MSSgPUZSm1431tsVNdRUxdo9"
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
    
            print("----- BEFORE SEND ------")
            Alamofire.request(request).responseString { (response) in
                print(response)
            }
            print("----- AFTER SEND ------")
            
    }
    
    public func attentionToJson(attention: [Attention]) -> [Any] {
        var jsonAttArray: [Any] = []
        
        for att in attention {
            let jsonAttention: [String : Any] = [
                "nbPerson" : att.nbPerson,
                "timestamp" : att.timestamp
            ]
            jsonAttArray.append(jsonAttention)
        }
        
        return jsonAttArray
    }
    
    public func dataToJson(data: VideoRecordStats) -> [String : Any] {
        let jsonData: [String : Any] = [
            "skipped" : data.skipped,
            "skippedTime" : data.skippedTime,
            "videoId" : data.videoId,
            "phoneId" : data.phoneId,
            "attention" : attentionToJson(attention: data.attention)
        ]
        return jsonData
    }
    
    // load videos from the server
    public func loadRandomVideo(completion: @escaping (String?, String?)->()) {
        //        var token = "Bearer JGYMkqcLBLjE9hGvmuqfjlgVgph8IO6uQkDK7hgYRYvNRTx7PgVC9kmUVQJPY5wdP3qECpNJiOWq4UsyJ41RLCYLojvhP8hS1yDqeyQNPCbqpo2tcxll4wKswnToQeio1totg0Xk9y2rPLRUEQvGg3LH1llVV449UtA9ole5Kp26HNFnkenXN4niDqucxBN06u9ssFlPEajVRukKmYAMemXplEq2eByvyxdREtM9dNTRt8crvHvDHaX4TaimQhEc"
        
        guard let url = URL(string: serverAddress + "/api/video/getLink") else
        {
            return
        }
        Alamofire.request(url, method: .get, headers: ["PhoneIdentifiers" : phoneId,
                                                       "type" : "iOS",
                                                       "model" : modelName])
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
                            self.videoFilename = JSON.object(forKey: "videoFilename") as? String
                            self.videoImgUri = JSON.object(forKey: "thumbnailFilename") as? String
                            print(JSON)
                        completion(self.videoId, self.videoFilename)
                    }
                    
                }
    }

}

/*
 ** Data structure for sending to the server
 */
public struct VideoRecordStats : Codable {
    public var skipped: Bool
    public var skippedTime: Int64
    public var videoId: Int64
    public var phoneId: String
    public var timeZone: String
    public var modelName: String
    public var attention: [Attention]
}
public struct Attention : Codable {
    public var nbPerson: Int
    public var timestamp: Double
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
