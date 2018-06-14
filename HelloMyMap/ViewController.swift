//
//  ViewController.swift
//  HelloMyMap
//
//  Created by Jim on 2018/6/6.
//  Copyright © 2018年 Jim. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation //定位

extension  ViewController :CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //只有更新時 才會執行
        
        guard let coordinate = locations.last?.coordinate else {
            assertionFailure("Invalid coordinate.")     //  只有debug 時候才有效。（表示程式邏輯有瑕痴 會讓app crash）
            return
        }
        print("Coordinate: \(coordinate.latitude), \(coordinate.longitude)  ")
    }
}

extension UIViewController: MKMapViewDelegate {//沒有呼叫。可能1 func字打錯(方法再打一次有顯示表示 就是打錯字了)
    // 加入中斷點 可以看是否能run到這邊
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //
        let region = mapView.region
        print("Center: \(region.center.longitude) ,\(region.center.longitude)")
        print("Span1: \(region.span.latitudeDelta) ,\(region.span.longitudeDelta)")
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //。MK point  Annotation 來的
        if annotation is MKUserLocation {  //保留預設圖標 回傳nil 不改變 使用者位置的圖標
            return nil
        }
        
        guard let   annotation = annotation as? StoreAnntation else {
            assertionFailure("Fail to cast the annotation.")
            return nil
            
        }
        print("\(annotation.storeID) , \(annotation.storeType) ")
        
        let identifier = "Store"  // Annotation  的名稱
//        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        // Create one if no exist one
        if result == nil {//沒人回收 創一個
//            result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)  //父的版本
            
        }else{        //轉成父型 空的針
            result?.annotation = annotation   //回收回來 再用。   （單純資料）。有view才有顯示
        }
        result?.canShowCallout = true   //為了讓 show出來
        
        
//        result?.pinTintColor = .blue  //改色
//        result?.animatesDrop = true     //吸引目光的動畫
        
        let image = UIImage(named: "pointRed.png")
        result?.image = image //必須符合的定規格
        
        
        //Prepare Left-callout accessoey view
        result?.leftCalloutAccessoryView = UIImageView(image: image)
        
        let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(calloutBtnTapped(sneder:)), for: .touchUpInside)
        result?.rightCalloutAccessoryView = button
        
//        result?.detailCalloutAccessoryView = ...
        
        //ＧＣＤ 多核心 用Queue 來切 分配任務份量（分給cpu核心）
        return result

    }
    
    @objc   //會被select 包起來
    func calloutBtnTapped(sneder:Any)  {
        print("callOutBtnTapped!")
    }
    
    
    
}

class ViewController: UIViewController  {

    let locationManager = CLLocationManager()  //產生物件
    
    @IBOutlet weak var mainMapView: MKMapView!
    
    @IBAction func mapTypeChange(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            mainMapView.mapType = .standard
        case 1:
            mainMapView.mapType = .satellite
        case 2:
            mainMapView.mapType = .hybrid
        case 3:
            mainMapView.mapType = .satelliteFlyover
            let coordinate = CLLocationCoordinate2DMake(35.710063, 139.8107)
            
            let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 800, pitch: 65, heading: 0)  //距離,仰角,決定相機視角 heading 向北
            
            mainMapView.camera = camera
            
            
        default:
            mainMapView.mapType = .standard
        }
        
    }
    @IBAction func useTrackingModeChange(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 1:
            mainMapView.userTrackingMode = .none
        case 2:
            mainMapView.userTrackingMode = .follow
        case 3:
            mainMapView.userTrackingMode = .followWithHeading
        
        default:
            mainMapView.userTrackingMode = .none
        }
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        guard let location = locationManager.location else {
            print("Location is  not ready")
            return
        }
        
//        //Demo how to show annotition view only when it is not too far form user.
//        let stores = [
//            CLLocation(latitude: 24.987, longitude: 121.510),
//            CLLocation(latitude: 24.887, longitude: 121.410),
//            CLLocation(latitude: 24.900, longitude: 121.610),
//
//        ]
//
//        for storeLocation in stores {
//            // Ckeck if the distance of each store.
//            guard location.distance(from: storeLocation) < 3000 else{  //擋掉 3000以下
//
//                continue
//            }
//            //...
//        }
        
        
        // Add a annotation at fake place
        var storeCoodinate = location.coordinate//裡面是strut。 //struct  定義是放資料
        storeCoodinate.latitude += 0.005
        storeCoodinate.longitude += 0.005
        
//        let annotation = MKPointAnnotation() //放資料 放大頭針。annotation註解  //會傳到view For annotation
        let annotation = StoreAnntation()
        annotation.coordinate = storeCoodinate
        annotation.title = "肯德基"
        annotation.subtitle = "真好吃"
        
        annotation.storeID = 123
        annotation.storeType = .seven
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0  ) {  //延後一秒執行  //塞給main(thread) 要調度的任務進入排隊
            self.mainMapView.addAnnotation(annotation)
        }
        
        // Move and Zoom the map to the storeCoordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)//自己會校正 會更改經緯度其一
        let region = MKCoordinateRegion(center: storeCoodinate, span: span)
        
         mainMapView.setRegion(region, animated: false)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ask use's permission
        locationManager.requestAlwaysAuthorization()  //總是授權
        
        //Background location update support.
        locationManager.allowsBackgroundLocationUpdates = true
        //不完善 所以選擇不自動更新
        locationManager.pausesLocationUpdatesAutomatically = false
        
        
        mainMapView.delegate = self
        
        guard CLLocationManager.locationServicesEnabled() else {
            //Show hint to user...
            return
        }
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else{
            //Show hint to user...
            return
        }
        
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest//區分等級從best開始用gps  //desiredAccuracy 期待準確（方法未知）
            locationManager.activityType = .automotiveNavigation
            locationManager.distanceFilter = 20.0     //最小 無移動距離 公尺為單位。 （模擬機 無差別）
        
        
            locationManager.startUpdatingLocation()
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

enum StoreType {
    case hilife
    case family
    case seven
    case none
}

class StoreAnntation: MKPointAnnotation {
    var storeID = -1
    var storeType = StoreType.none
}





