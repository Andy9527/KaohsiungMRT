//
//  StationTimeTableView.swift
//  KaohsiungMRT
//
//  Created by CHIA CHUN LI on 2021/3/29.
//

import UIKit

class StationTimeTableView: UITableView,UITableViewDataSource{
    
    var instance:StationTimeTableViewController! = nil
    
    //時刻表數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalData.arrivalTimeArr.count
    }
    
    //顯示時刻表
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeTableTVC") as! StationTimeTableViewCell
        
        cell.arrivalTimeLabel.text = GlobalData.arrivalTimeArr[indexPath.row]
        
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
