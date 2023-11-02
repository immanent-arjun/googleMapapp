//
//  ViewController.swift
//  maps
//
//  Created by Sonoma on 01/11/23.
//
import CoreLocation
import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON


class ViewController: UIViewController,GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    let manager = CLLocationManager()
    var sourceLat = Double()
    var soucreLan = Double()
    let destinationlat = 26.4499
    let destinationlan = 80.3319
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        mapView.animate(toZoom: 11)
    }
    
    func UpdateCurrentLocation(sourceLat:Double,soucreLan:Double){
        let sourceLocation = "\(sourceLat),\(soucreLan)"
        let destinationLocation = "\(destinationlat),\(destinationlan)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLocation)&destination=\(destinationLocation)&mode=driving&key=AIzaSyCPcbBU1EZv5uFhG_3IIMT9PUjn8-sdk6M"
        AF.request(url).response{ response in
            guard let data = response.data else {return}
            do{
                let jsonData = try JSON(data: data)
                let routes = jsonData["routes"].arrayValue
                
                for route in routes {
                    let overview_ployline = route["overview_polyline"].dictionary
                    guard let points = overview_ployline?["points"]?.string else {return}
                    let path = GMSPath.init(fromEncodedPath: points)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeColor = .systemGreen
                    polyline.strokeWidth = 5
                    polyline.map = self.mapView
                    let legs = route["legs"].arrayValue
                    for leg in legs {
                        let distance = leg["distance"].dictionary
                        guard let text = distance?["text"]?.string else {return}
                        self.distance.text = "Distance: " + text
                        let duration = leg["duration"].dictionary
                        guard let time = duration?["text"]?.string else {return}
                        self.time.text = "Duration :" + time
                        
                    }
                }
            }
            catch{
                print(error.localizedDescription)
            }
            
        }
        let destinationMarker = GMSMarker()
        destinationMarker.position = CLLocationCoordinate2D(latitude: destinationlat, longitude: destinationlan)
        destinationMarker.title = "Rock Garden"
        destinationMarker.map = self.mapView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
             let coordinate = location.coordinate
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude:coordinate.longitude))
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 8)
            UpdateCurrentLocation(sourceLat: coordinate.latitude,
                                  soucreLan: coordinate.longitude)
        }
    }
}

