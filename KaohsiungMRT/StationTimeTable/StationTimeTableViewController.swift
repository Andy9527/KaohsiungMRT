//
//  StationTimeTableViewController.swift
//  KaohsiungMRT
//
//  Created by CHIA CHUN LI on 2021/3/28.
//

import UIKit
import GoogleMobileAds

class StationTimeTableViewController: UIViewController {

    @IBOutlet weak var stationTimeTable: StationTimeTableView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var todayDateLabel: UILabel!
    
    var todayDateString = ""
    var weekdayString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissBtn.addTarget(self, action: #selector(dismissBtnClick(_:)), for: .touchUpInside)
        coverView.isHidden = true
        activityIndicator.isHidden = true
        
        stationNameLabel.text = GlobalData.selectStationName
        
        //取得星期幾
        let dataFormatter = DateFormatter()
        dataFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dataFormatter.dateFormat = "yyyy-MM-dd"
        todayDateString = dataFormatter.string(from: Date())
        let calender = Calendar(identifier:Calendar.Identifier.gregorian)
        let comps = (calender as NSCalendar?)?.components(NSCalendar.Unit.weekday, from: Date())
        
        switch comps?.weekday {
        case 1?:
            weekdayString = "星期日"
        case 2?:
            weekdayString = "星期一"
        case 3?:
            weekdayString = "星期二"
        case 4?:
            weekdayString = "星期三"
        case 5?:
            weekdayString = "星期四"
        case 6?:
            weekdayString = "星期五"
        case 7?:
            weekdayString = "星期六"
        default:
            break
        }
        
        todayDateLabel.text = todayDateString + " " + weekdayString
       
        stationTimeTable.dataSource = stationTimeTable.self
        stationTimeTable.instance = self
        
        //設定GADBannerView properties
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        //美麗島站是R10與O5
        if GlobalData.selectStationID == "R10" && GlobalData.endStationID == "OT1"{
            GlobalData.selectStationID = "O5"
        }else if GlobalData.selectStationID == "R10" && GlobalData.endStationID == "O1"{
            GlobalData.selectStationID = "O5"
        }
        //高雄捷運時刻表API串接
        let request = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/StationTimeTable/KRTC?$filter=StationID%20eq%20'\(GlobalData.selectStationID)'%20and%20DestinationStaionID%20eq%20'\(GlobalData.endStationID)'&$format=JSON")
        URLSession.shared.dataTask(with: request) { (data, respnse, error) in
            
            do{
                
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String:AnyObject]]
                //print("json data=\(jsonData)")
                
                //時刻表分星期一到四 星期五 週六日三種 這裡做星期幾判斷以顯示對應時刻表
                DispatchQueue.main.async {
                    if self.weekdayString == "星期一" || self.weekdayString == "星期二" || self.weekdayString == "星期三" || self.weekdayString == "星期四"{
                        
                        let weekdayDic = jsonData[0]["Timetables"] as! [[String:AnyObject]]
                        
                        for weekday in weekdayDic{
                            GlobalData.arrivalTimeArr.append(weekday["ArrivalTime"] as! String)
                            //print("arrival time arr=\(GlobalData.arrivalTimeArr)")
                        }
                        //print("arrival time arr count=\(GlobalData.arrivalTimeArr.count)")
                        //print("weekdayDic=\(weekdayDic)")
                        self.stationTimeTable.reloadData()
                        
                    }else if self.weekdayString == "星期五"{
                        
                        let fridayDic = jsonData[1]["Timetables"] as! [[String:AnyObject]]
                        
                        for friday in fridayDic{
                            GlobalData.arrivalTimeArr.append(friday["ArrivalTime"] as! String)
                            //print("arrival time arr=\(GlobalData.arrivalTimeArr)")
                        }
                        //print("arrival time arr count=\(GlobalData.arrivalTimeArr.count)")
                        //print("weekdayDic=\(weekdayDic)")
                        self.stationTimeTable.reloadData()
                        
                    }else if self.weekdayString == "星期六" || self.weekdayString == "星期日"{
                        let holidayDic = jsonData[2]["Timetables"] as! [[String:AnyObject]]
                        
                        for holiday in holidayDic{
                            GlobalData.arrivalTimeArr.append(holiday["ArrivalTime"] as! String)
                            //print("arrival time arr=\(GlobalData.arrivalTimeArr)")
                        }
                        //print("arrival time arr count=\(GlobalData.arrivalTimeArr.count)")
                        //print("weekdayDic=\(weekdayDic)")
                        DispatchQueue.main.async {
                            self.stationTimeTable.reloadData()
                        }
                        
                    }
                }
                
            }catch{
                
                
                
            }
           
        }.resume()
        
       
        
       

        // Do any additional setup after loading the view.
    }
    @objc func dismissBtnClick(_ sender:UIButton){
        GlobalData.arrivalTimeArr = []
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
