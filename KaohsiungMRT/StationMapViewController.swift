//
//  StationMapViewController.swift
//  KaohsiungMRT
//
//  Created by CHIA CHUN LI on 2021/3/28.
//

import UIKit
import GoogleMobileAds
import MapKit
import CoreLocation
import Network
import RealmSwift
import CommonCrypto
import SwiftyJSON


class StationMapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var stationTimeTableBtn: UIButton!
    @IBOutlet weak var stationFareBtn: UIButton!
    @IBOutlet weak var firstAndLastTimeBtn: UIButton!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var immediateTimeTableBtn: UIButton!
    @IBOutlet weak var navigationBtn: UIButton!
    @IBOutlet weak var centerToUserLocationBtn: UIButton!
    
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    
    var locationManager = CLLocationManager()
    var selectAnnotationCoor:CLLocationCoordinate2D!
    var currentLocationCoor:CLLocationCoordinate2D!
    var userLocation:CLLocationCoordinate2D!
    
    var stationIDDic = [String:String]()
    
    var stationLocationArr = [StationLocation]()
    var stationGatewayArr = [StationGateway]()
    var yellowStationLocationArr = [CLLocationCoordinate2D(latitude: 22.621783, longitude: 120.274541),CLLocationCoordinate2D(latitude: 22.623517, longitude: 120.28378),CLLocationCoordinate2D(latitude: 22.628924, longitude: 120.294567),CLLocationCoordinate2D(latitude: 22.631392, longitude: 120.301912),CLLocationCoordinate2D(latitude: 22.630735, longitude: 120.311447),CLLocationCoordinate2D(latitude: 22.630271, longitude: 120.317765),CLLocationCoordinate2D(latitude: 22.627312, longitude: 120.334588),CLLocationCoordinate2D(latitude: 22.625209, longitude: 120.340888),CLLocationCoordinate2D(latitude: 22.62529, longitude: 120.34827),CLLocationCoordinate2D(latitude: 22.625993, longitude: 120.355857),CLLocationCoordinate2D(latitude: 22.625282, longitude: 120.36316),CLLocationCoordinate2D(latitude: 22.624923, longitude: 120.372483),CLLocationCoordinate2D(latitude: 22.622223, longitude: 120.390429)]
    
    var redStationLocationArr = [CLLocationCoordinate2D(latitude: 22.780623, longitude: 120.301732),CLLocationCoordinate2D(latitude: 22.760253, longitude: 120.310973),CLLocationCoordinate2D(latitude: 22.753493, longitude: 120.314454),CLLocationCoordinate2D(latitude: 22.744393, longitude: 120.317617),CLLocationCoordinate2D(latitude: 22.72934, longitude: 120.321002),CLLocationCoordinate2D(latitude: 22.722357, longitude: 120.316236),CLLocationCoordinate2D(latitude: 22.718699, longitude: 120.30707),CLLocationCoordinate2D(latitude: 22.708695, longitude: 120.302163),CLLocationCoordinate2D(latitude: 22.701878, longitude: 120.302472),CLLocationCoordinate2D(latitude: 22.687856, longitude: 120.309124),CLLocationCoordinate2D(latitude: 22.676708, longitude: 120.306574),CLLocationCoordinate2D(latitude: 22.66636, longitude: 120.303134),CLLocationCoordinate2D(latitude: 22.657078, longitude: 120.303254),CLLocationCoordinate2D(latitude: 22.648503, longitude: 120.303359),CLLocationCoordinate2D(latitude: 22.638007, longitude: 120.302813),CLLocationCoordinate2D(latitude: 22.631392, longitude: 120.301912),CLLocationCoordinate2D(latitude: 22.624851, longitude: 120.301106),CLLocationCoordinate2D(latitude: 22.613961, longitude: 120.304584),CLLocationCoordinate2D(latitude: 22.606049, longitude: 120.308082),CLLocationCoordinate2D(latitude: 22.596794, longitude: 120.315435),CLLocationCoordinate2D(latitude: 22.588356, longitude: 120.321743),CLLocationCoordinate2D(latitude: 22.580376, longitude: 120.32876),CLLocationCoordinate2D(latitude: 22.570087, longitude: 120.341746),CLLocationCoordinate2D(latitude: 22.564813, longitude: 120.353812)]
    
    var redPolyline:MKPolyline?
    var yellowPolyline:MKPolyline?
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [self] path in
           
            switch path.status {
            case .satisfied:
                print("connect")
                
                if CLLocationManager.locationServicesEnabled(){

                    // 首次使用 向使用者詢問定位自身位置權限
                    if locationManager.authorizationStatus
                        == .notDetermined {
                        // 取得定位服務授權
                        locationManager.requestWhenInUseAuthorization()
                       
                    }
                    // 使用者已經拒絕定位自身位置權限
                    else if locationManager.authorizationStatus
                                == .denied {
                        // 提示可至[設定]中開啟權限
                        DispatchQueue.main.async {
                            let errorAlert = self.createErrorAlert(alertControllerTitle: "定位權限已關閉", alertActionTitle: "確定", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                            self.present(errorAlert, animated: true, completion: nil)
                        }

                    }
                    // 使用者已經同意定位自身位置權限
                    else if locationManager.authorizationStatus
                                == .authorizedWhenInUse {
                        locationManager.delegate = self
                        // 開始定位自身位置
                        locationManager.startUpdatingLocation()
                    }

                }else{

                    DispatchQueue.main.async {
                        let errorAlert = self.createErrorAlert(alertControllerTitle: "定位權限已關閉", alertActionTitle: "確定", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                        self.present(errorAlert, animated: true, completion: nil)
                    }


                }
            case .unsatisfied:
                //print("not connect")
                DispatchQueue.main.async {
                    let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "確定", message: "網路連線品質不佳", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            case .requiresConnection:
                //print("not connect")
                DispatchQueue.main.async {
                    let errorAlert = self.createErrorAlert(alertControllerTitle: "無網路", alertActionTitle: "確定", message: "請連線網路", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            default:
                break
            }
         
            
        }
        //開始偵測網路
        monitor.start(queue: DispatchQueue.global())
        //print("網路狀態=\(monitor.currentPath.status)")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        coverView.isHidden = true
        activityIndicator.isHidden = true
        stationTimeTableBtn.addTarget(self, action: #selector(stationTimeTableBtnClick(_:)), for: .touchUpInside)
        stationFareBtn.addTarget(self, action: #selector(stationFareBtnClick(_:)), for: .touchUpInside)
        firstAndLastTimeBtn.addTarget(self, action: #selector(firstAndLastTimeBtnClick(_:)), for: .touchUpInside)
        immediateTimeTableBtn.addTarget(self, action: #selector(immediateTimeTableBtnClick(_:)), for: .touchUpInside)
        navigationBtn.addTarget(self, action: #selector(navigationBtnClick(_:)), for: .touchUpInside)
        centerToUserLocationBtn.addTarget(self, action: #selector(centerToUserLocationBtnClick(_:)), for: .touchUpInside)
        
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            //設定定位精準度
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //設定代理
            self.locationManager.delegate = self
            self.locationManager.showsBackgroundLocationIndicator = true
            //取得使用者座標
            self.userLocation = self.locationManager.location?.coordinate
        }
            
            
        //顯示使用者位置
        self.myMap.showsUserLocation = true
        //可縮放
        self.myMap.isZoomEnabled = true
        //顯示指北針
        self.myMap.showsCompass = true
        //設定region
        let region = self.regionWithUserLocation(latitudeDelta: 0.01, longitudeDelta: 0.01, userLocation: self.userLocation)
        self.myMap.setRegion(region, animated: true)
        //設定代理器
        self.myMap.delegate = self
        
        
        //取得一度
        let oneDegree = CGFloat.pi / 180
        
        DispatchQueue.main.async {
            //轉90度
            self.bottomImage.transform = CGAffineTransform(rotationAngle: oneDegree * 90)
            //轉180度
            self.leftImage.transform = CGAffineTransform(rotationAngle: oneDegree * 180)
            //轉270度
            self.topImage.transform = CGAffineTransform(rotationAngle: oneDegree * 270)
        }
        
//        let realm = try! Realm()
//        try! realm.write{
//            realm.deleteAll()
//        }
        
        //從Realm資料庫取出類別實體
        let loactionRealm = try! Realm()
        let locationResult = loactionRealm.objects(StationLocation.self)
        self.stationLocationArr = Array(locationResult)
          
        //print("station location arr count=\(stationLocationArr.count)")
       
        if stationLocationArr.count == 0{
            
            //高雄捷運站點API串接
            let stationAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/Station/KRTC?$format=JSON")
            URLSession.shared.dataTask(with: stationAPIRequest) { [self] (data, response, error) in
                
                let urlResponse = response as! HTTPURLResponse
                let statusCode = urlResponse.statusCode
                
                if statusCode == 200{
                    do{
                        let jsonData:JSON = try JSON(data: data!)
                        for i in 0..<jsonData.count{
                            
                            let stationLocation = StationLocation()
                            stationLocation.stationID = jsonData[i]["StationID"].string!
                            stationLocation.stationName = jsonData[i]["StationName"]["Zh_tw"].string!
                            stationLocation.stationLat = jsonData[i]["StationPosition"]["PositionLat"].double!
                            stationLocation.stationLon = jsonData[i]["StationPosition"]["PositionLon"].double!
                            
                            let realm = try! Realm()
                            //將存入對應值的類別存入Realm資料庫
                            try! realm.write{
                                realm.add(stationLocation)
                            }
                          
                        }
                        
                        //從Realm資料庫取出類別實體
                        let realm = try! Realm()
                        let result = realm.objects(StationLocation.self)
                        self.stationLocationArr = Array(result)
                        //print("content=\(results)")
                        
                        for result in self.stationLocationArr{
                        
                            //取出類別的經緯度與資訊插在地圖上
                            let annotation = createAnnotation(latitude:result.stationLat, longitude: result.stationLon, title:result.stationName, subtitle: "")
                            
                            DispatchQueue.main.async {
                                self.myMap.addAnnotation(annotation)
                            }
                            
                        }
                      
                      
                    }catch{
                        
                    }
                }else{
                    
                }
            
                }.resume()
            
            
        }else{
            //從Realm資料庫取出類別實體
            let realm = try! Realm()
            let result = realm.objects(StationLocation.self)
            self.stationLocationArr = Array(result)
            //print("content=\(results)")
            
            
            for result in self.stationLocationArr{
                
               
                //取出類別的經緯度與資訊插在地圖上
                let annotation = createAnnotation(latitude:result.stationLat, longitude: result.stationLon, title:result.stationName, subtitle: "")
                
                DispatchQueue.main.async {
                    self.myMap.addAnnotation(annotation)
                }
                
            }
           
        }
        
        //從Realm資料庫取出類別實體
        let gatewayRealm = try! Realm()
        let gatewayResult = gatewayRealm.objects(StationGateway.self)
        self.stationGatewayArr = Array(gatewayResult)
        
        //高雄捷運出入口站點API串接
        if stationGatewayArr.count == 0{
            let gatewayAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/StationExit/KRTC?$format=JSON")
            URLSession.shared.dataTask(with: gatewayAPIRequest) { [self] (data, response, error) in
                    
                let urlResponse = response as! HTTPURLResponse
                let statusCode = urlResponse.statusCode
                
                if statusCode == 200{
                    do{
                        let jsonData:JSON = try JSON(data: data!)
                        for i in 0..<jsonData.count{
                            
                            let stationGatway = StationGateway()
                            stationGatway.stationID = jsonData[i]["StationID"].string!
                            stationGatway.stationName = jsonData[i]["ExitName"]["Zh_tw"].string!
                            stationGatway.stationLat = jsonData[i]["ExitPosition"]["PositionLat"].double!
                            stationGatway.stationLon = jsonData[i]["ExitPosition"]["PositionLon"].double!
                            
                            let realm = try! Realm()
                            //將存入對應值的類別存入Realm資料庫
                            try! realm.write{
                                realm.add(stationGatway)
                            }
                          
                        }
                        
                        //從Realm資料庫取出類別實體
                        let realm = try! Realm()
                        let result = realm.objects(StationGateway.self)
                        self.stationGatewayArr = Array(result)
                        //print("content=\(results)")
                        
                        
                        for result in self.stationGatewayArr{
                            //取出類別的經緯度與資訊插在地圖上
                            let annotation = createAnnotation(latitude:result.stationLat, longitude: result.stationLon, title:result.stationName, subtitle: "")
                            
                            DispatchQueue.main.async {
                                self.myMap.addAnnotation(annotation)
                            }
                            
                        }
                        //let stationName = jsonData[0]["StationName"]["Zh_tw"].string
                        //print("station name=\(stationName)")
                        
                    }catch{
                        
                    }
                }else{
                    
                }
                
            }.resume()
        }else{
            //從Realm資料庫取出類別實體
            let realm = try! Realm()
            let result = realm.objects(StationGateway.self)
            self.stationGatewayArr = Array(result)
            //print("content=\(results)")
            
            
            for result in self.stationGatewayArr{
                //取出類別的經緯度與資訊插在地圖上
                let annotation = createAnnotation(latitude:result.stationLat, longitude: result.stationLon, title:result.stationName, subtitle: "")
                
                DispatchQueue.main.async {
                    self.myMap.addAnnotation(annotation)
                }
                
            }
            
        }
        
        DispatchQueue.main.async {
                //在地圖上畫線將站點連再一起
                self.redPolyline = MKPolyline(coordinates: self.redStationLocationArr, count: self.redStationLocationArr.count)
                self.myMap.addOverlay(self.redPolyline!)
            
                self.yellowPolyline = MKPolyline(coordinates: self.yellowStationLocationArr, count: self.yellowStationLocationArr.count)
                self.myMap.addOverlay(self.yellowPolyline!)
           
          
        }
       
       
        //執行廣告
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
    }
    //執行導航
    @objc func navigationBtnClick(_ sender:UIButton){
        
        
         DispatchQueue.main.async {
             MKMapItem.openMaps(with: self.mapNavigation(startCoordinate: self.userLocation, endCoordinate: self.selectAnnotationCoor), launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
         }
        
        
    }
    //地圖中心回到使用者座標
    @objc func centerToUserLocationBtnClick(_ sender:UIButton){
        //設定region
        let region = self.regionWithUserLocation(latitudeDelta: 0.01, longitudeDelta: 0.01, userLocation: self.userLocation)
        self.myMap.setRegion(region, animated: true)
    }
    //時刻表
    @objc func stationTimeTableBtnClick(_ sender:UIButton){
 
        //判斷station id
        if GlobalData.selectStationID == ""{
            DispatchQueue.main.async {
                let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "確定", message: "請選擇站點", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }else if GlobalData.selectStationID == "R10"{
            //print("R10")
            
            //建立alert controller以及action做路線選擇
            let controller = UIAlertController(title: "請選擇路線方向", message: nil, preferredStyle: .actionSheet)
         
            let redNorthAction = GlobalData.stationSelectAction(title: "往南岡山站方向", style: .default, endStationID: "R24", vc: self, vcID: "stationTimeTable")
            let redSouthAction = GlobalData.stationSelectAction(title: "往小港站方向", style: .default, endStationID: "R3", vc: self, vcID: "stationTimeTable")
            let orangeEastAction = GlobalData.stationSelectAction(title: "往大寮方向", style: .default, endStationID: "OT1", vc: self, vcID: "stationTimeTable")
            let orangeWestAction = GlobalData.stationSelectAction(title: "往西子灣方向", style: .default, endStationID: "O1", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            controller.addAction(redNorthAction)
            controller.addAction(redSouthAction)
            controller.addAction(orangeEastAction)
            controller.addAction(orangeWestAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
            
        }else if GlobalData.selectStationID == "O1"{
            
            //建立alert controller以及action做路線選擇
            let controller = UIAlertController(title: "請選擇路線方向", message: nil, preferredStyle: .actionSheet)
          
            let orangeEastAction = GlobalData.stationSelectAction(title: "往大寮方向", style: .default, endStationID: "OT1", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
           
            controller.addAction(orangeEastAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID == "OT1"{
            
            //建立alert controller以及action做路線選擇
            let controller = UIAlertController(title: "請選擇路線方向", message: nil, preferredStyle: .actionSheet)
    
            let orangeWestAction = GlobalData.stationSelectAction(title: "往西子灣方向", style: .default, endStationID: "O1", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
            controller.addAction(orangeWestAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID == "R3"{
            
            //建立alert controller以及action做路線選擇
            let controller = UIAlertController(title: "請選擇路線方向", message: nil, preferredStyle: .actionSheet)
            
            let redNorthAction = GlobalData.stationSelectAction(title: "往南岡山站方向", style: .default, endStationID: "R24", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            controller.addAction(redNorthAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID == "R24"{
            
            //建立alert controller以及action做路線選擇
            let controller = UIAlertController(title: "請選擇路線方向", message: nil, preferredStyle: .actionSheet)
           
            let redSouthAction = GlobalData.stationSelectAction(title: "往小港站方向", style: .default, endStationID: "R3", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
            controller.addAction(redSouthAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID.contains("O"){
            //print("O")
            
            //建立alert controller以及action做路線選擇
            let controller = UIAlertController(title: "請選擇路線方向", message: nil, preferredStyle: .actionSheet)

            let orangeEastAction = GlobalData.stationSelectAction(title: "往大寮方向", style: .default, endStationID: "OT1", vc: self, vcID: "stationTimeTable")
            let orangeWestAction = GlobalData.stationSelectAction(title: "往西子灣方向", style: .default, endStationID: "O1", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
           
            controller.addAction(orangeEastAction)
            controller.addAction(orangeWestAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID.contains("R"){
            //print("R")
            
            //建立alert controller以及action做路線選擇
            let controller = UIAlertController(title: "請選擇路線方向", message: nil, preferredStyle: .actionSheet)
            let redNorthAction = GlobalData.stationSelectAction(title: "往南岡山站方向", style: .default, endStationID: "R24", vc: self, vcID: "stationTimeTable")
            let redSouthAction = GlobalData.stationSelectAction(title: "往小港站方向", style: .default, endStationID: "R3", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            controller.addAction(redNorthAction)
            controller.addAction(redSouthAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
        }
        
        
    }
    //票價
    @objc func stationFareBtnClick(_ sender:UIButton){
        
        //判斷有無選擇站點
        if GlobalData.selectStationID == ""{
            DispatchQueue.main.async {
                let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "確定", message: "請選擇站點", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }else{
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let fareVC = storyboard.instantiateViewController(identifier: "stationFare") as! StationFareViewController
                self.present(fareVC, animated: true, completion: nil)
            }
        }
        
        
        
    }
    //首末班車
    @objc func firstAndLastTimeBtnClick(_ sender:UIButton){
        
        //判斷有無選擇站點
        if GlobalData.selectStationID == ""{
            DispatchQueue.main.async {
                let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "確定", message: "請選擇站點", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }else if GlobalData.selectStationID == "R10"{
            //因美麗島站同時是R10與O5 所以如果是美麗島要多串接一個O5
            let controller = UIAlertController(title: GlobalData.selectStationName, message: nil, preferredStyle: .actionSheet)
            
            //取得該站點首末班車API串接
            let firstAndLastAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/FirstLastTimetable/KRTC?$filter=StationID%20eq%20'\("O5")'&$format=JSON")
            
            URLSession.shared.dataTask(with: firstAndLastAPIRequest) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        
                        for i in 0..<jsonData.count{
                            print("i=\(i)")
                            //出發站點
                            let startStationName = jsonData[i]["StationName"]["Zh_tw"].string
                            //終點站
                            let endStationName = jsonData[i]["DestinationStationName"]["Zh_tw"].string
                            //print("start=\(startStationName)")
                            //print("end=\(endStationName)")
                           
                            //判斷出發與終點是否為同一個站點 一樣就跳過
                            if startStationName != endStationName{
                                //前往路線
                                let boundFor = jsonData[i]["TripHeadSign"].string!
                                //首班車
                                let firstTime = jsonData[i]["FirstTrainTime"].string!
                                //末班車
                                let lastTime = jsonData[i]["LastTrainTime"].string!
                                //print("bound for=\(boundFor)")
                                //print("first time=\(firstTime)")
                                //print("last time=\(lastTime)")
                                

                                let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                                boundForAction.isEnabled = false
                                
                                let firstTimeAction = GlobalData.showTimeAction(title: "首班車:"+firstTime, style: .default)
                                firstTimeAction.isEnabled = false
                                
                                let lastTimeAction = GlobalData.showTimeAction(title: "末班車:"+lastTime, style: .default)
                                lastTimeAction.isEnabled = false
                               
                                controller.addAction(boundForAction)
                                controller.addAction(firstTimeAction)
                                controller.addAction(lastTimeAction)
                            }
                        }
                       
                        
                    }catch{
                        
                    }
                }
                
                
            }.resume()
            
            //取得該站點首末班車API串接
            let firstAndLastAPIRequest2 = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/FirstLastTimetable/KRTC?$filter=StationID%20eq%20'\(GlobalData.selectStationID)'&$format=JSON")
            URLSession.shared.dataTask(with: firstAndLastAPIRequest2) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        
                        for i in 0..<jsonData.count{
                            print("i=\(i)")
                            //起點站
                            let startStationName = jsonData[i]["StationName"]["Zh_tw"].string
                            //終點站
                            let endStationName = jsonData[i]["DestinationStationName"]["Zh_tw"].string
                            //print("start=\(startStationName)")
                            //print("end=\(endStationName)")
                           
                            //判斷起點站與終點站是否一樣 一樣就跳過
                            if startStationName != endStationName{
                                //前往路線
                                let boundFor = jsonData[i]["TripHeadSign"].string!
                                //首班車
                                let firstTime = jsonData[i]["FirstTrainTime"].string!
                                //末班車
                                let lastTime = jsonData[i]["LastTrainTime"].string!
                                //print("bound for=\(boundFor)")
                                //print("first time=\(firstTime)")
                                //print("last time=\(lastTime)")
                                

                                let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                                boundForAction.isEnabled = false
                                
                                let firstTimeAction = GlobalData.showTimeAction(title: "首班車:"+firstTime, style: .default)
                                firstTimeAction.isEnabled = false
                                
                                let lastTimeAction = GlobalData.showTimeAction(title: "末班車:"+lastTime, style: .default)
                                lastTimeAction.isEnabled = false
                               
                                controller.addAction(boundForAction)
                                controller.addAction(firstTimeAction)
                                controller.addAction(lastTimeAction)
                            }
                        }
                        
                        //時間格式的轉換
                        let updateTime = jsonData[0]["UpdateTime"].string!
                        
                        let dateFMT = DateFormatter()
                        dateFMT.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        let date = dateFMT.date(from:updateTime)
                        
                        let dateFMT2 = DateFormatter()
                        dateFMT2.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateString = dateFMT2.string(from: date!)
                        
                        let updateTimeAction = GlobalData.showTimeAction(title: dateString, style: .default)
                        updateTimeAction.isEnabled = false
                        controller.addAction(updateTimeAction)
                       
                        
                    }catch{
                        
                    }
                }
                
                
            }.resume()
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
            
        }else{
            //美麗島站以外無需另外處理O5 取得station id正常串接首末班車API即可
            let firstAndLastAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/FirstLastTimetable/KRTC?$filter=StationID%20eq%20'\(GlobalData.selectStationID)'&$format=JSON")
            URLSession.shared.dataTask(with: firstAndLastAPIRequest) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        let controller = UIAlertController(title: GlobalData.selectStationName, message: nil, preferredStyle: .actionSheet)
                        
                        for i in 0..<jsonData.count{
                            print("i=\(i)")
                            //起點站
                            let startStationName = jsonData[i]["StationName"]["Zh_tw"].string
                            //終點站
                            let endStationName = jsonData[i]["DestinationStationName"]["Zh_tw"].string
                            //print("start=\(startStationName)")
                            //print("end=\(endStationName)")
                            
                            //判斷起點站與終點站是否一樣 一樣就跳過
                            if startStationName != endStationName{
                                //前往路線
                                let boundFor = jsonData[i]["TripHeadSign"].string!
                                //首班車
                                let firstTime = jsonData[i]["FirstTrainTime"].string!
                                //末班車
                                let lastTime = jsonData[i]["LastTrainTime"].string!
                                //print("bound for=\(boundFor)")
                                //print("first time=\(firstTime)")
                                //print("last time=\(lastTime)")
                                

                                let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                                boundForAction.isEnabled = false
                                
                                let firstTimeAction = GlobalData.showTimeAction(title: "首班車:"+firstTime, style: .default)
                                firstTimeAction.isEnabled = false
                                
                                let lastTimeAction = GlobalData.showTimeAction(title: "末班車:"+lastTime, style: .default)
                                lastTimeAction.isEnabled = false
                               
                                controller.addAction(boundForAction)
                                controller.addAction(firstTimeAction)
                                controller.addAction(lastTimeAction)
                            }
                        }
                        //時間格式處理
                        let updateTime = jsonData[0]["UpdateTime"].string!
                        
                        let dateFMT = DateFormatter()
                        dateFMT.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        let date = dateFMT.date(from:updateTime)
                        
                        let dateFMT2 = DateFormatter()
                        dateFMT2.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateString = dateFMT2.string(from: date!)
                        
                        let updateTimeAction = GlobalData.showTimeAction(title: dateString, style: .default)
                        updateTimeAction.isEnabled = false
                        controller.addAction(updateTimeAction)
                        
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                        
                    }catch{
                        
                    }
                }
                
                
            }.resume()
        }
        
        
    }
    
    
    //即時到離站
    @objc func immediateTimeTableBtnClick(_ sender:UIButton){
      
        //判斷station id
        if GlobalData.selectStationID == ""{
            DispatchQueue.main.async {
                let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "確定", message: "請選擇站點", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }else if GlobalData.selectStationID == "R10"{
            //美麗島站同時是R10與O5 需另外串接直是O5的API
            //controller and action顯示資訊
            let controller = UIAlertController(title: GlobalData.selectStationName, message: nil, preferredStyle: .actionSheet)
            
            let immediateTimeAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/LiveBoard/KRTC?$filter=StationID%20eq%20'O5'&$format=JSON")
            
            URLSession.shared.dataTask(with: immediateTimeAPIRequest) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        
                        for i in 0..<jsonData.count{
                            //print("i=\(i)")
                         
                            //前往路線
                            let boundFor = jsonData[i]["TripHeadSign"].string!
                            //預估到站時間
                            let estimateTime = jsonData[i]["EstimateTime"].int!
                            let estimateTimeString = String(estimateTime)
                             
                            let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                            boundForAction.isEnabled = false
                            
                            let estimateTimeAction = GlobalData.showTimeAction(title: "預估:" + estimateTimeString + "(分)", style: .default)
                            estimateTimeAction.isEnabled = false
                            
                            controller.addAction(boundForAction)
                            controller.addAction(estimateTimeAction)
                             
                        }
                       
                    }catch{
                        
                    }
                }
                
                
            }.resume()
            
            
            let immediateTimeAPIRequest2 = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/LiveBoard/KRTC?$filter=StationID%20eq%20'\(GlobalData.selectStationID)'&$format=JSON")
            URLSession.shared.dataTask(with: immediateTimeAPIRequest2) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        
                        for i in 0..<jsonData.count{
                            //print("i=\(i)")
                            
                            //前往路線
                            let boundFor = jsonData[i]["TripHeadSign"].string!
                            //預估到站時間
                            let estimateTime = jsonData[i]["EstimateTime"].int!
                            let estimateTimeString = String(estimateTime)
                             
                            let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                            boundForAction.isEnabled = false
                            
                            let estimateTimeAction = GlobalData.showTimeAction(title: "預估:" + estimateTimeString + "(分)", style: .default)
                            estimateTimeAction.isEnabled = false
                            
                            controller.addAction(boundForAction)
                            controller.addAction(estimateTimeAction)
                            
                        }
                        //時間格式處理
                        let updateTime = jsonData[0]["UpdateTime"].string!
                        
                        let dateFMT = DateFormatter()
                        dateFMT.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        let date = dateFMT.date(from:updateTime)
                        
                        let dateFMT2 = DateFormatter()
                        dateFMT2.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateString = dateFMT2.string(from: date!)
                        
                        let updateTimeAction = GlobalData.showTimeAction(title: dateString, style: .default)
                        updateTimeAction.isEnabled = false
                        controller.addAction(updateTimeAction)
                        
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                       
                        
                    }catch{
                        
                    }
                }
                
                
            }.resume()
            
           
        }else{
            //美麗島以外站點取得station id串接即時到離站API即可
            let immediateTimeAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/LiveBoard/KRTC?$filter=StationID%20eq%20'\(GlobalData.selectStationID)'&$format=JSON")
            URLSession.shared.dataTask(with: immediateTimeAPIRequest) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        //controller and action顯示資訊
                        let controller = UIAlertController(title: GlobalData.selectStationName, message: nil, preferredStyle: .actionSheet)
                        
                        for i in 0..<jsonData.count{
                            //print("i=\(i)")
                            //前往路線
                            let boundFor = jsonData[i]["TripHeadSign"].string!
                            //預估到站時間
                            let estimateTime = jsonData[i]["EstimateTime"].int!
                            let estimateTimeString = String(estimateTime)
                             
                            let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                            boundForAction.isEnabled = false
                            
                            let estimateTimeAction = GlobalData.showTimeAction(title: "預估:" + estimateTimeString + "(分)", style: .default)
                            estimateTimeAction.isEnabled = false
                            
                            controller.addAction(boundForAction)
                            controller.addAction(estimateTimeAction)
                            
                        }
                        let updateTime = jsonData[0]["UpdateTime"].string!
                        
                        let dateFMT = DateFormatter()
                        dateFMT.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        let date = dateFMT.date(from:updateTime)
                        
                        let dateFMT2 = DateFormatter()
                        dateFMT2.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateString = dateFMT2.string(from: date!)
                        
                        let updateTimeAction = GlobalData.showTimeAction(title: dateString, style: .default)
                        updateTimeAction.isEnabled = false
                        controller.addAction(updateTimeAction)
                        
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                        
                    }catch{
                        
                    }
                }
                
                
            }.resume()
        }
        
       
    }
    
    //導航
    func mapNavigation(startCoordinate:CLLocationCoordinate2D,endCoordinate:CLLocationCoordinate2D) -> [MKMapItem]{
        
        //初始化目的地MKPlacmark
        let endPlaceMark = MKPlacemark(coordinate:endCoordinate)
        //透過placeMark初始化一個MKMapItem
        let endMapItem = MKMapItem(placemark:endPlaceMark)
        //初始化使用者MKPlacemark
        let startPlaceMark = MKPlacemark(coordinate:startCoordinate)
        //透過placeMark初始化一個MKMapItem
        let startMapItem = MKMapItem(placemark:startPlaceMark)
        //建立導航路線起點與終點
        let routes = [startMapItem,endMapItem]
        
        return routes
            
    }
    
    //顯示annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //如果使用者無需顯示annotation view
        if annotation is MKUserLocation{
            return nil
        }
       
        //建立annotationv view物件
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        //可否顯示callout
        pin.canShowCallout = true
        //更換圖片
//        let pinImage = UIImage(named: "mrtStation.png")
//        pin.image = pinImage
    
        return pin
        
    }
    
    //更新使用者位置 取得使用者位置經緯度
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 印出目前所在位置座標
        let currentLocation :CLLocation =
            locations[0] as CLLocation
        currentLocationCoor = currentLocation.coordinate
        
        //print("user location coor=\(currentLocation.coordinate)")
        
    }
    //錯誤警告視窗
    func createErrorAlert(alertControllerTitle:String, alertActionTitle:String,message:String,alertControllerStyle:UIAlertController.Style, alertActionStyle:UIAlertAction.Style,viewController:UIViewController) -> UIAlertController{
        //建立alert controller物件
        let alert = UIAlertController(title: alertControllerTitle, message: message, preferredStyle: alertControllerStyle)
        //建立alert action物件
        let action = UIAlertAction(title: alertActionTitle, style: alertActionStyle) { (action) in
            viewController.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        
        return alert

    }
    //輸入經緯度顯示位置
   func createAnnotation(latitude:Double,longitude:Double,title:String,subtitle:String) -> MKPointAnnotation{
        
        //建立annotation物件
        let annotation = MKPointAnnotation()
        //設定annotation經緯度
        annotation.coordinate = CLLocationCoordinate2DMake(latitude,longitude)
        //設定anntation title and subtitle
        annotation.title = title
        annotation.subtitle = subtitle
        
        return annotation
        
    }
    
    //回到使用者中心點位置
    @objc func userLocationCenterBtnClick(_ sender:UIButton){
        
        //取得使用者座標
        let userLocation = locationManager.location?.coordinate
        //設定region
        let region = regionWithUserLocation(latitudeDelta: 0.03, longitudeDelta: 0.03, userLocation: userLocation!)
        myMap.setRegion(region, animated: true)
        
    }
   
    
    //當定位點被點擊時
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //取得被點擊Annotation的Coordinate
        GlobalData.selectStationName = (view.annotation?.title!)!
        selectAnnotationCoor = view.annotation?.coordinate
        //print("select location=\(selectAnnotationCoor)")
        //print("user location=\(userLocation)")
        
        //從Realm資料庫取出類別實體
        let stationRealm = try! Realm()
        let stationResult = stationRealm.objects(StationLocation.self)
        self.stationLocationArr = Array(stationResult)
        //print("content=\(results)")
        for result in self.stationLocationArr{
            if result.stationName == GlobalData.selectStationName{
                GlobalData.selectStationID = result.stationID
            }
        }
        
        //從Realm資料庫取出類別實體
        let gatewayRealm = try! Realm()
        let gatewayResult = gatewayRealm.objects(StationGateway.self)
        self.stationGatewayArr = Array(gatewayResult)
        //print("content=\(results)")
        for result in self.stationGatewayArr{
            if result.stationName == GlobalData.selectStationName{
                GlobalData.selectStationID = result.stationID
            }
        }
        print("select station id=\(GlobalData.selectStationID)")
        
        //GlobalData.selectStationID = stationIDDic[GlobalData.selectStationName]!
        
        //print("select station id=\(GlobalData.selectStationID)")
        //print("click")
        //print("select annotation coordinate=\(selectAnnotationCoor)")
        
    }
    //將地圖顯示區域以使用者定位中心為準
    func regionWithUserLocation(latitudeDelta:CLLocationDegrees,longitudeDelta:CLLocationDegrees,userLocation:CLLocationCoordinate2D) -> MKCoordinateRegion{
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        
        return region
        
    }
   
    //地圖畫線參數設定
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let redPolyline = overlay as? MKPolyline{
            let renderer = MKPolylineRenderer(polyline: redPolyline)
            renderer.strokeColor = UIColor.red.withAlphaComponent(0.9)
            renderer.lineWidth = 3
            return renderer
        }
        
      
        return MKOverlayRenderer()
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
