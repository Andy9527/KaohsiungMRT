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

                    // ???????????? ??????????????????????????????????????????
                    if locationManager.authorizationStatus
                        == .notDetermined {
                        // ????????????????????????
                        locationManager.requestWhenInUseAuthorization()
                       
                    }
                    // ?????????????????????????????????????????????
                    else if locationManager.authorizationStatus
                                == .denied {
                        // ????????????[??????]???????????????
                        DispatchQueue.main.async {
                            let errorAlert = self.createErrorAlert(alertControllerTitle: "?????????????????????", alertActionTitle: "??????", message: "??????????????????????????? ?????? > ????????? > ???????????? ??????", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                            self.present(errorAlert, animated: true, completion: nil)
                        }

                    }
                    // ?????????????????????????????????????????????
                    else if locationManager.authorizationStatus
                                == .authorizedWhenInUse {
                        locationManager.delegate = self
                        // ????????????????????????
                        locationManager.startUpdatingLocation()
                    }

                }else{

                    DispatchQueue.main.async {
                        let errorAlert = self.createErrorAlert(alertControllerTitle: "?????????????????????", alertActionTitle: "??????", message: "??????????????????????????? ?????? > ????????? > ???????????? ??????", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                        self.present(errorAlert, animated: true, completion: nil)
                    }


                }
            case .unsatisfied:
                //print("not connect")
                DispatchQueue.main.async {
                    let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "??????", message: "????????????????????????", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            case .requiresConnection:
                //print("not connect")
                DispatchQueue.main.async {
                    let errorAlert = self.createErrorAlert(alertControllerTitle: "?????????", alertActionTitle: "??????", message: "???????????????", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            default:
                break
            }
         
            
        }
        //??????????????????
        monitor.start(queue: DispatchQueue.global())
        //print("????????????=\(monitor.currentPath.status)")
        
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
            //?????????????????????
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //????????????
            self.locationManager.delegate = self
            self.locationManager.showsBackgroundLocationIndicator = true
            //?????????????????????
            self.userLocation = self.locationManager.location?.coordinate
        }
            
            
        //?????????????????????
        self.myMap.showsUserLocation = true
        //?????????
        self.myMap.isZoomEnabled = true
        //???????????????
        self.myMap.showsCompass = true
        //??????region
        let region = self.regionWithUserLocation(latitudeDelta: 0.01, longitudeDelta: 0.01, userLocation: self.userLocation)
        self.myMap.setRegion(region, animated: true)
        //???????????????
        self.myMap.delegate = self
        
        
        //????????????
        let oneDegree = CGFloat.pi / 180
        
        DispatchQueue.main.async {
            //???90???
            self.bottomImage.transform = CGAffineTransform(rotationAngle: oneDegree * 90)
            //???180???
            self.leftImage.transform = CGAffineTransform(rotationAngle: oneDegree * 180)
            //???270???
            self.topImage.transform = CGAffineTransform(rotationAngle: oneDegree * 270)
        }
        
//        let realm = try! Realm()
//        try! realm.write{
//            realm.deleteAll()
//        }
        
        //???Realm???????????????????????????
        let loactionRealm = try! Realm()
        let locationResult = loactionRealm.objects(StationLocation.self)
        self.stationLocationArr = Array(locationResult)
          
        //print("station location arr count=\(stationLocationArr.count)")
       
        if stationLocationArr.count == 0{
            
            //??????????????????API??????
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
                            //?????????????????????????????????Realm?????????
                            try! realm.write{
                                realm.add(stationLocation)
                            }
                          
                        }
                        
                        //???Realm???????????????????????????
                        let realm = try! Realm()
                        let result = realm.objects(StationLocation.self)
                        self.stationLocationArr = Array(result)
                        //print("content=\(results)")
                        
                        for result in self.stationLocationArr{
                        
                            //????????????????????????????????????????????????
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
            //???Realm???????????????????????????
            let realm = try! Realm()
            let result = realm.objects(StationLocation.self)
            self.stationLocationArr = Array(result)
            //print("content=\(results)")
            
            
            for result in self.stationLocationArr{
                
               
                //????????????????????????????????????????????????
                let annotation = createAnnotation(latitude:result.stationLat, longitude: result.stationLon, title:result.stationName, subtitle: "")
                
                DispatchQueue.main.async {
                    self.myMap.addAnnotation(annotation)
                }
                
            }
           
        }
        
        //???Realm???????????????????????????
        let gatewayRealm = try! Realm()
        let gatewayResult = gatewayRealm.objects(StationGateway.self)
        self.stationGatewayArr = Array(gatewayResult)
        
        //???????????????????????????API??????
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
                            //?????????????????????????????????Realm?????????
                            try! realm.write{
                                realm.add(stationGatway)
                            }
                          
                        }
                        
                        //???Realm???????????????????????????
                        let realm = try! Realm()
                        let result = realm.objects(StationGateway.self)
                        self.stationGatewayArr = Array(result)
                        //print("content=\(results)")
                        
                        
                        for result in self.stationGatewayArr{
                            //????????????????????????????????????????????????
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
            //???Realm???????????????????????????
            let realm = try! Realm()
            let result = realm.objects(StationGateway.self)
            self.stationGatewayArr = Array(result)
            //print("content=\(results)")
            
            
            for result in self.stationGatewayArr{
                //????????????????????????????????????????????????
                let annotation = createAnnotation(latitude:result.stationLat, longitude: result.stationLon, title:result.stationName, subtitle: "")
                
                DispatchQueue.main.async {
                    self.myMap.addAnnotation(annotation)
                }
                
            }
            
        }
        
        DispatchQueue.main.async {
                //???????????????????????????????????????
                self.redPolyline = MKPolyline(coordinates: self.redStationLocationArr, count: self.redStationLocationArr.count)
                self.myMap.addOverlay(self.redPolyline!)
            
                self.yellowPolyline = MKPolyline(coordinates: self.yellowStationLocationArr, count: self.yellowStationLocationArr.count)
                self.myMap.addOverlay(self.yellowPolyline!)
           
          
        }
       
       
        //????????????
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
    }
    //????????????
    @objc func navigationBtnClick(_ sender:UIButton){
        
        
         DispatchQueue.main.async {
             MKMapItem.openMaps(with: self.mapNavigation(startCoordinate: self.userLocation, endCoordinate: self.selectAnnotationCoor), launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
         }
        
        
    }
    //?????????????????????????????????
    @objc func centerToUserLocationBtnClick(_ sender:UIButton){
        //??????region
        let region = self.regionWithUserLocation(latitudeDelta: 0.01, longitudeDelta: 0.01, userLocation: self.userLocation)
        self.myMap.setRegion(region, animated: true)
    }
    //?????????
    @objc func stationTimeTableBtnClick(_ sender:UIButton){
 
        //??????station id
        if GlobalData.selectStationID == ""{
            DispatchQueue.main.async {
                let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "??????", message: "???????????????", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }else if GlobalData.selectStationID == "R10"{
            //print("R10")
            
            //??????alert controller??????action???????????????
            let controller = UIAlertController(title: "?????????????????????", message: nil, preferredStyle: .actionSheet)
         
            let redNorthAction = GlobalData.stationSelectAction(title: "?????????????????????", style: .default, endStationID: "R24", vc: self, vcID: "stationTimeTable")
            let redSouthAction = GlobalData.stationSelectAction(title: "??????????????????", style: .default, endStationID: "R3", vc: self, vcID: "stationTimeTable")
            let orangeEastAction = GlobalData.stationSelectAction(title: "???????????????", style: .default, endStationID: "OT1", vc: self, vcID: "stationTimeTable")
            let orangeWestAction = GlobalData.stationSelectAction(title: "??????????????????", style: .default, endStationID: "O1", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
            
            controller.addAction(redNorthAction)
            controller.addAction(redSouthAction)
            controller.addAction(orangeEastAction)
            controller.addAction(orangeWestAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
            
        }else if GlobalData.selectStationID == "O1"{
            
            //??????alert controller??????action???????????????
            let controller = UIAlertController(title: "?????????????????????", message: nil, preferredStyle: .actionSheet)
          
            let orangeEastAction = GlobalData.stationSelectAction(title: "???????????????", style: .default, endStationID: "OT1", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
           
            controller.addAction(orangeEastAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID == "OT1"{
            
            //??????alert controller??????action???????????????
            let controller = UIAlertController(title: "?????????????????????", message: nil, preferredStyle: .actionSheet)
    
            let orangeWestAction = GlobalData.stationSelectAction(title: "??????????????????", style: .default, endStationID: "O1", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
        
            controller.addAction(orangeWestAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID == "R3"{
            
            //??????alert controller??????action???????????????
            let controller = UIAlertController(title: "?????????????????????", message: nil, preferredStyle: .actionSheet)
            
            let redNorthAction = GlobalData.stationSelectAction(title: "?????????????????????", style: .default, endStationID: "R24", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
            
            controller.addAction(redNorthAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID == "R24"{
            
            //??????alert controller??????action???????????????
            let controller = UIAlertController(title: "?????????????????????", message: nil, preferredStyle: .actionSheet)
           
            let redSouthAction = GlobalData.stationSelectAction(title: "??????????????????", style: .default, endStationID: "R3", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
        
            controller.addAction(redSouthAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID.contains("O"){
            //print("O")
            
            //??????alert controller??????action???????????????
            let controller = UIAlertController(title: "?????????????????????", message: nil, preferredStyle: .actionSheet)

            let orangeEastAction = GlobalData.stationSelectAction(title: "???????????????", style: .default, endStationID: "OT1", vc: self, vcID: "stationTimeTable")
            let orangeWestAction = GlobalData.stationSelectAction(title: "??????????????????", style: .default, endStationID: "O1", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
           
            controller.addAction(orangeEastAction)
            controller.addAction(orangeWestAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
        }else if GlobalData.selectStationID.contains("R"){
            //print("R")
            
            //??????alert controller??????action???????????????
            let controller = UIAlertController(title: "?????????????????????", message: nil, preferredStyle: .actionSheet)
            let redNorthAction = GlobalData.stationSelectAction(title: "?????????????????????", style: .default, endStationID: "R24", vc: self, vcID: "stationTimeTable")
            let redSouthAction = GlobalData.stationSelectAction(title: "??????????????????", style: .default, endStationID: "R3", vc: self, vcID: "stationTimeTable")
            let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
            
            controller.addAction(redNorthAction)
            controller.addAction(redSouthAction)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
        }
        
        
    }
    //??????
    @objc func stationFareBtnClick(_ sender:UIButton){
        
        //????????????????????????
        if GlobalData.selectStationID == ""{
            DispatchQueue.main.async {
                let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "??????", message: "???????????????", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
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
    //????????????
    @objc func firstAndLastTimeBtnClick(_ sender:UIButton){
        
        //????????????????????????
        if GlobalData.selectStationID == ""{
            DispatchQueue.main.async {
                let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "??????", message: "???????????????", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }else if GlobalData.selectStationID == "R10"{
            //????????????????????????R10???O5 ??????????????????????????????????????????O5
            let controller = UIAlertController(title: GlobalData.selectStationName, message: nil, preferredStyle: .actionSheet)
            
            //???????????????????????????API??????
            let firstAndLastAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/FirstLastTimetable/KRTC?$filter=StationID%20eq%20'\("O5")'&$format=JSON")
            
            URLSession.shared.dataTask(with: firstAndLastAPIRequest) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        
                        for i in 0..<jsonData.count{
                            print("i=\(i)")
                            //????????????
                            let startStationName = jsonData[i]["StationName"]["Zh_tw"].string
                            //?????????
                            let endStationName = jsonData[i]["DestinationStationName"]["Zh_tw"].string
                            //print("start=\(startStationName)")
                            //print("end=\(endStationName)")
                           
                            //????????????????????????????????????????????? ???????????????
                            if startStationName != endStationName{
                                //????????????
                                let boundFor = jsonData[i]["TripHeadSign"].string!
                                //?????????
                                let firstTime = jsonData[i]["FirstTrainTime"].string!
                                //?????????
                                let lastTime = jsonData[i]["LastTrainTime"].string!
                                //print("bound for=\(boundFor)")
                                //print("first time=\(firstTime)")
                                //print("last time=\(lastTime)")
                                

                                let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                                boundForAction.isEnabled = false
                                
                                let firstTimeAction = GlobalData.showTimeAction(title: "?????????:"+firstTime, style: .default)
                                firstTimeAction.isEnabled = false
                                
                                let lastTimeAction = GlobalData.showTimeAction(title: "?????????:"+lastTime, style: .default)
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
            
            //???????????????????????????API??????
            let firstAndLastAPIRequest2 = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/FirstLastTimetable/KRTC?$filter=StationID%20eq%20'\(GlobalData.selectStationID)'&$format=JSON")
            URLSession.shared.dataTask(with: firstAndLastAPIRequest2) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        
                        for i in 0..<jsonData.count{
                            print("i=\(i)")
                            //?????????
                            let startStationName = jsonData[i]["StationName"]["Zh_tw"].string
                            //?????????
                            let endStationName = jsonData[i]["DestinationStationName"]["Zh_tw"].string
                            //print("start=\(startStationName)")
                            //print("end=\(endStationName)")
                           
                            //??????????????????????????????????????? ???????????????
                            if startStationName != endStationName{
                                //????????????
                                let boundFor = jsonData[i]["TripHeadSign"].string!
                                //?????????
                                let firstTime = jsonData[i]["FirstTrainTime"].string!
                                //?????????
                                let lastTime = jsonData[i]["LastTrainTime"].string!
                                //print("bound for=\(boundFor)")
                                //print("first time=\(firstTime)")
                                //print("last time=\(lastTime)")
                                

                                let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                                boundForAction.isEnabled = false
                                
                                let firstTimeAction = GlobalData.showTimeAction(title: "?????????:"+firstTime, style: .default)
                                firstTimeAction.isEnabled = false
                                
                                let lastTimeAction = GlobalData.showTimeAction(title: "?????????:"+lastTime, style: .default)
                                lastTimeAction.isEnabled = false
                               
                                controller.addAction(boundForAction)
                                controller.addAction(firstTimeAction)
                                controller.addAction(lastTimeAction)
                            }
                        }
                        
                        //?????????????????????
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
            
            let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
            
            
        }else{
            //????????????????????????????????????O5 ??????station id????????????????????????API??????
            let firstAndLastAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/FirstLastTimetable/KRTC?$filter=StationID%20eq%20'\(GlobalData.selectStationID)'&$format=JSON")
            URLSession.shared.dataTask(with: firstAndLastAPIRequest) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        let controller = UIAlertController(title: GlobalData.selectStationName, message: nil, preferredStyle: .actionSheet)
                        
                        for i in 0..<jsonData.count{
                            print("i=\(i)")
                            //?????????
                            let startStationName = jsonData[i]["StationName"]["Zh_tw"].string
                            //?????????
                            let endStationName = jsonData[i]["DestinationStationName"]["Zh_tw"].string
                            //print("start=\(startStationName)")
                            //print("end=\(endStationName)")
                            
                            //??????????????????????????????????????? ???????????????
                            if startStationName != endStationName{
                                //????????????
                                let boundFor = jsonData[i]["TripHeadSign"].string!
                                //?????????
                                let firstTime = jsonData[i]["FirstTrainTime"].string!
                                //?????????
                                let lastTime = jsonData[i]["LastTrainTime"].string!
                                //print("bound for=\(boundFor)")
                                //print("first time=\(firstTime)")
                                //print("last time=\(lastTime)")
                                

                                let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                                boundForAction.isEnabled = false
                                
                                let firstTimeAction = GlobalData.showTimeAction(title: "?????????:"+firstTime, style: .default)
                                firstTimeAction.isEnabled = false
                                
                                let lastTimeAction = GlobalData.showTimeAction(title: "?????????:"+lastTime, style: .default)
                                lastTimeAction.isEnabled = false
                               
                                controller.addAction(boundForAction)
                                controller.addAction(firstTimeAction)
                                controller.addAction(lastTimeAction)
                            }
                        }
                        //??????????????????
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
                        
                        let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                        
                    }catch{
                        
                    }
                }
                
                
            }.resume()
        }
        
        
    }
    
    
    //???????????????
    @objc func immediateTimeTableBtnClick(_ sender:UIButton){
      
        //??????station id
        if GlobalData.selectStationID == ""{
            DispatchQueue.main.async {
                let errorAlert = self.createErrorAlert(alertControllerTitle: "", alertActionTitle: "??????", message: "???????????????", alertControllerStyle: .alert, alertActionStyle: UIAlertAction.Style.default, viewController: self)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }else if GlobalData.selectStationID == "R10"{
            //?????????????????????R10???O5 ?????????????????????O5???API
            //controller and action????????????
            let controller = UIAlertController(title: GlobalData.selectStationName, message: nil, preferredStyle: .actionSheet)
            
            let immediateTimeAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/LiveBoard/KRTC?$filter=StationID%20eq%20'O5'&$format=JSON")
            
            URLSession.shared.dataTask(with: immediateTimeAPIRequest) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        
                        for i in 0..<jsonData.count{
                            //print("i=\(i)")
                         
                            //????????????
                            let boundFor = jsonData[i]["TripHeadSign"].string!
                            //??????????????????
                            let estimateTime = jsonData[i]["EstimateTime"].int!
                            let estimateTimeString = String(estimateTime)
                             
                            let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                            boundForAction.isEnabled = false
                            
                            let estimateTimeAction = GlobalData.showTimeAction(title: "??????:" + estimateTimeString + "(???)", style: .default)
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
                            
                            //????????????
                            let boundFor = jsonData[i]["TripHeadSign"].string!
                            //??????????????????
                            let estimateTime = jsonData[i]["EstimateTime"].int!
                            let estimateTimeString = String(estimateTime)
                             
                            let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                            boundForAction.isEnabled = false
                            
                            let estimateTimeAction = GlobalData.showTimeAction(title: "??????:" + estimateTimeString + "(???)", style: .default)
                            estimateTimeAction.isEnabled = false
                            
                            controller.addAction(boundForAction)
                            controller.addAction(estimateTimeAction)
                            
                        }
                        //??????????????????
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
                        
                        let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                       
                        
                    }catch{
                        
                    }
                }
                
                
            }.resume()
            
           
        }else{
            //???????????????????????????station id?????????????????????API??????
            let immediateTimeAPIRequest = GlobalData.urlStringToRequest(urlString: "https://ptx.transportdata.tw/MOTC/v2/Rail/Metro/LiveBoard/KRTC?$filter=StationID%20eq%20'\(GlobalData.selectStationID)'&$format=JSON")
            URLSession.shared.dataTask(with: immediateTimeAPIRequest) { (data, response, error) in
                
                DispatchQueue.main.async {
                    do{
                        
                        let jsonData = try JSON(data: data!)
                        //print("json data=\(jsonData)")
                        
                        //controller and action????????????
                        let controller = UIAlertController(title: GlobalData.selectStationName, message: nil, preferredStyle: .actionSheet)
                        
                        for i in 0..<jsonData.count{
                            //print("i=\(i)")
                            //????????????
                            let boundFor = jsonData[i]["TripHeadSign"].string!
                            //??????????????????
                            let estimateTime = jsonData[i]["EstimateTime"].int!
                            let estimateTimeString = String(estimateTime)
                             
                            let boundForAction = GlobalData.showTimeAction(title: boundFor, style: .default)
                            boundForAction.isEnabled = false
                            
                            let estimateTimeAction = GlobalData.showTimeAction(title: "??????:" + estimateTimeString + "(???)", style: .default)
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
                        
                        let cancelAction = UIAlertAction(title: "??????", style: .cancel, handler: nil)
                        controller.addAction(cancelAction)
                        self.present(controller, animated: true, completion: nil)
                        
                    }catch{
                        
                    }
                }
                
                
            }.resume()
        }
        
       
    }
    
    //??????
    func mapNavigation(startCoordinate:CLLocationCoordinate2D,endCoordinate:CLLocationCoordinate2D) -> [MKMapItem]{
        
        //??????????????????MKPlacmark
        let endPlaceMark = MKPlacemark(coordinate:endCoordinate)
        //??????placeMark???????????????MKMapItem
        let endMapItem = MKMapItem(placemark:endPlaceMark)
        //??????????????????MKPlacemark
        let startPlaceMark = MKPlacemark(coordinate:startCoordinate)
        //??????placeMark???????????????MKMapItem
        let startMapItem = MKMapItem(placemark:startPlaceMark)
        //?????????????????????????????????
        let routes = [startMapItem,endMapItem]
        
        return routes
            
    }
    
    //??????annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //???????????????????????????annotation view
        if annotation is MKUserLocation{
            return nil
        }
       
        //??????annotationv view??????
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        //????????????callout
        pin.canShowCallout = true
        //????????????
//        let pinImage = UIImage(named: "mrtStation.png")
//        pin.image = pinImage
    
        return pin
        
    }
    
    //????????????????????? ??????????????????????????????
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // ??????????????????????????????
        let currentLocation :CLLocation =
            locations[0] as CLLocation
        currentLocationCoor = currentLocation.coordinate
        
        //print("user location coor=\(currentLocation.coordinate)")
        
    }
    //??????????????????
    func createErrorAlert(alertControllerTitle:String, alertActionTitle:String,message:String,alertControllerStyle:UIAlertController.Style, alertActionStyle:UIAlertAction.Style,viewController:UIViewController) -> UIAlertController{
        //??????alert controller??????
        let alert = UIAlertController(title: alertControllerTitle, message: message, preferredStyle: alertControllerStyle)
        //??????alert action??????
        let action = UIAlertAction(title: alertActionTitle, style: alertActionStyle) { (action) in
            viewController.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        
        return alert

    }
    //???????????????????????????
   func createAnnotation(latitude:Double,longitude:Double,title:String,subtitle:String) -> MKPointAnnotation{
        
        //??????annotation??????
        let annotation = MKPointAnnotation()
        //??????annotation?????????
        annotation.coordinate = CLLocationCoordinate2DMake(latitude,longitude)
        //??????anntation title and subtitle
        annotation.title = title
        annotation.subtitle = subtitle
        
        return annotation
        
    }
    
    //??????????????????????????????
    @objc func userLocationCenterBtnClick(_ sender:UIButton){
        
        //?????????????????????
        let userLocation = locationManager.location?.coordinate
        //??????region
        let region = regionWithUserLocation(latitudeDelta: 0.03, longitudeDelta: 0.03, userLocation: userLocation!)
        myMap.setRegion(region, animated: true)
        
    }
   
    
    //????????????????????????
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //???????????????Annotation???Coordinate
        GlobalData.selectStationName = (view.annotation?.title!)!
        selectAnnotationCoor = view.annotation?.coordinate
        //print("select location=\(selectAnnotationCoor)")
        //print("user location=\(userLocation)")
        
        //???Realm???????????????????????????
        let stationRealm = try! Realm()
        let stationResult = stationRealm.objects(StationLocation.self)
        self.stationLocationArr = Array(stationResult)
        //print("content=\(results)")
        for result in self.stationLocationArr{
            if result.stationName == GlobalData.selectStationName{
                GlobalData.selectStationID = result.stationID
            }
        }
        
        //???Realm???????????????????????????
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
    //???????????????????????????????????????????????????
    func regionWithUserLocation(latitudeDelta:CLLocationDegrees,longitudeDelta:CLLocationDegrees,userLocation:CLLocationCoordinate2D) -> MKCoordinateRegion{
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        
        return region
        
    }
   
    //????????????????????????
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
