//
//  GlobalData.swift
//  KaohsiungMRT
//
//  Created by CHIA CHUN LI on 2021/3/29.
//

import Foundation
import CommonCrypto
import CoreLocation
import UIKit


class GlobalData{
    
    static var selectStationID = ""
    static var endStationID = ""
    static var selectStationName = ""
    static var arrivalTimeArr = [String]()
    static var stationFareDic = [String:Array<Any>]()
    static var stationFareDicArr = [[String:Array<Any>]]()
   
    static func dateFormatterConvert(stringFMT:String,toConvertStringFMT:String,dateString:String) -> String{
        
        let dateFMT = DateFormatter()
        dateFMT.dateFormat = stringFMT
        let date = dateFMT.date(from: dateString)
        let newDateFMT = DateFormatter()
        newDateFMT.dateFormat = toConvertStringFMT
        let newDate = newDateFMT.string(from: date ?? Date())
        
        return newDate
        
    }
    //站點時刻表路線選擇
    static func stationSelectAction(title:String,style:UIAlertAction.Style,endStationID:String,vc:UIViewController,vcID:String) -> UIAlertAction{
        
        let action = UIAlertAction(title: title, style: style) { (action) in
            
            GlobalData.endStationID = endStationID
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let timeTableVC = storyboard.instantiateViewController(identifier: vcID)
                vc.present(timeTableVC, animated: true, completion: nil)
            }
        }
        return action
    }
    //首末班車顯示
    static func showTimeAction(title:String,style:UIAlertAction.Style) -> UIAlertAction{
        
        let action = UIAlertAction(title: title, style: style) { (action) in
            
        }
        return action
    }
    
    
    
    enum CryptoAlgorithm {

        case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

        var HMACAlgorithm: CCHmacAlgorithm {
            var result: Int = 0
            switch self {
            case .MD5:      result = kCCHmacAlgMD5
            case .SHA1:     result = kCCHmacAlgSHA1
            case .SHA224:   result = kCCHmacAlgSHA224
            case .SHA256:   result = kCCHmacAlgSHA256
            case .SHA384:   result = kCCHmacAlgSHA384
            case .SHA512:   result = kCCHmacAlgSHA512
            }
            return CCHmacAlgorithm(result)
        }

        var digestLength: Int {
            var result: Int32 = 0
            switch self {
            case .MD5:      result = CC_MD5_DIGEST_LENGTH
            case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
            case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
            case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
            case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
            case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
            }
            return Int(result)
        }
    }
    
    static func getServerTime() -> String {
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "EEE, dd MMM yyyy HH:mm:ww zzz"
        dateFormater.locale = Locale(identifier: "en_US")
        dateFormater.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormater.string(from: Date())
    }
    
    static func urlStringToRequest(urlString:String) -> URLRequest{
        
        let APIUrl = urlString
        let APP_ID = "8374e419a1954a2480ef98dc9420cbe7"
        let APP_KEY = "bE1-AeoXWhSPfKXNujfs0I4iABw"
        
        let xdate:String = GlobalData.getServerTime()
        let signDate = "x-date: " + xdate;
        
        let base64HmacStr = signDate.hmac(algorithm: .SHA1, key: APP_KEY)
        let authorization:String = "hmac username=\""+APP_ID+"\", algorithm=\"hmac-sha1\", headers=\"x-date\", signature=\""+base64HmacStr+"\""
        
        let url = URL(string: APIUrl)
        var request = URLRequest(url: url!)
        
        request.setValue(xdate, forHTTPHeaderField: "x-date")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        
        return request
        
    }

    
   
    
    
}

extension String {

    func hmac(algorithm: GlobalData.CryptoAlgorithm, key: String) -> String {

        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        let digestLen = algorithm.digestLength
        var result = [CUnsignedChar](repeating: 0, count: digestLen)
        CCHmac(algorithm.HMACAlgorithm, cKey!, strlen(cKey!), cData!, strlen(cData!), &result)
        let hmacData:Data = Data(bytes: result, count: digestLen)
        let hmacBase64 = hmacData.base64EncodedString(options: .lineLength64Characters)

        return String(hmacBase64)
    }
}

