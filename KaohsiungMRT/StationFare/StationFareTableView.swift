//
//  StationFareTableView.swift
//  KaohsiungMRT
//
//  Created by CHIA CHUN LI on 2021/3/30.
//

import UIKit

class StationFareTableView: UITableView,UITableViewDataSource{
    
    //票價資料數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalData.stationFareDicArr.count
    }
    //顯示票價
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "fareTVC") as! StationFareTableViewCell
        
        let stationFareDic = GlobalData.stationFareDicArr[indexPath.row]
        let startStationName = stationFareDic.keys.first
        let endStationName = stationFareDic[startStationName!]![0] as! String
        let adultFare = stationFareDic[startStationName!]![1] as! String
        let studentFare = stationFareDic[startStationName!]![2] as! String
        let childFare = stationFareDic[startStationName!]![3] as! String
        
        cell.startStationNameLabel.text = startStationName!
        cell.endStationNameLabel.text = endStationName
        cell.adultFareLabel.text = "成人:" + adultFare + "(元)"
        cell.studentFareLabel.text = "學生:" + studentFare + "(元)"
        cell.childFareLabel.text = "孩童:" + childFare + "(元)"
        //print("start station name=\(startStationName)")
        //print("station fare arr=\(stationFareArr)")
        
        return cell
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
