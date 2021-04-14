//
//  StationFareViewController.swift
//  KaohsiungMRT
//
//  Created by CHIA CHUN LI on 2021/3/28.
//

import UIKit
import GoogleMobileAds
import SwiftyJSON

class StationFareViewController: UIViewController {

    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationFareTable: StationFareTableView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        coverView.isHidden = true
        dismissBtn.addTarget(self, action: #selector(dismissBtnClick(_:)), for: .touchUpInside)
        
        stationNameLabel.text = GlobalData.selectStationName
        
        stationFareTable.dataSource = stationFareTable.self
        
        //設定GADBannerView properties
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
       
        //取得該站點station id串接票價API
        let stationFareAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/ODFare/KRTC?$filter=OriginStationID%20eq%20'\(GlobalData.selectStationID)'&$format=JSON")
        URLSession.shared.dataTask(with: stationFareAPIRequest) {(data, response, error) in
            
            do{
                let jsonData = try JSON(data: data!)
                //print("json data count=\(jsonData.count)")
                for i in 0..<jsonData.count{
                    
                    //起始站
                    let startStationName = jsonData[i]["OriginStationName"]["Zh_tw"].string!
                    //終點站
                    let endStationName = jsonData[i]["DestinationStationName"]["Zh_tw"].string!
                    //判斷起始站與終點站是否相同 一樣就跳過
                    if startStationName != endStationName{
                        //成人
                        let adultFare = String(jsonData[i]["Fares"][0]["Price"].int!)
                        //學生
                        let studentFare = String(jsonData[i]["Fares"][1]["Price"].int!)
                        //孩童
                        let childFare = String(jsonData[i]["Fares"][2]["Price"].int!)
                        
                        var fareArr = [String]()
                        fareArr.append(endStationName)
                        fareArr.append(adultFare)
                        fareArr.append(studentFare)
                        fareArr.append(childFare)
                       
                        
                        GlobalData.stationFareDic.updateValue(fareArr, forKey: startStationName)
                        GlobalData.stationFareDicArr.append(GlobalData.stationFareDic)
                    }
                    
                }
               
                //print("station fare dic arr=\( GlobalData.stationFareDicArr)")
                
                DispatchQueue.main.async {
                    self.stationFareTable.reloadData()
                }
                
                
            }catch{
                
            }
        
        }.resume()
        
        
        

        // Do any additional setup after loading the view.
    }
    @objc func dismissBtnClick(_ sender:UIButton){
        GlobalData.stationFareDic = [:]
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
