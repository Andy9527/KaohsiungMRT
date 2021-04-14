//
//  StationGatewayPosition.swift
//  KaohsiungMRT
//
//  Created by CHIA CHUN LI on 2021/3/30.
//

import Foundation
import RealmSwift

class StationGateway:Object{
    
    @objc dynamic var stationID = ""
    @objc dynamic var stationLat = 0.0
    @objc dynamic var stationLon = 0.0
    @objc dynamic var stationName = ""
    
    
}

