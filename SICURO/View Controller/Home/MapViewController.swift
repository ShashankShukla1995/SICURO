//
//  HomeViewController.swift
//  SICURO
//
//  Created by Shashank Shukla on 21/10/23.
//

import UIKit
import MapKit

struct Location {
    let title: String
    let coordinate: CLLocationCoordinate2D?
}

struct Steps {
    let step: MKRoute.Step
    let hasReachedStep: Bool
}

class MapViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var endLocationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bookCabButton: UIButton!
    
    let locationManager = CLLocationManager()
    var locations = [Location]()
    var searches : [MKMapItem] = []
    var sourceCoordinate: CLLocationCoordinate2D? = nil
    var destinationCoordinate: CLLocationCoordinate2D? = nil
    var steps:[MKRoute.Step] = []
    var stepCounter = 0
    var route: MKRoute?
    var showMapRoute = false
    var isOnRoute = true
    var isAuthorized = false
    
    let destinationTableView :UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        view.addSubview(destinationTableView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        destinationTableView.delegate = self
        destinationTableView.dataSource = self
        destinationTableView.isHidden = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 4
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        let tableY = endLocationTextField.frame.origin.y+endLocationTextField.frame.height+5
        destinationTableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
        endLocationTextField.addTarget(self, action: #selector(self.endLocationTextFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @IBAction func didTapStartTracking(_ sender: Any) {
        self.bookCabButton.isUserInteractionEnabled = false
        showMapRoute = true
        checkForPermission()
        if let location = locationManager.location {
            render(location)
        }
    }
    
    @objc func endLocationTextFieldDidChange(_ textField: UITextField) {
        if let text = endLocationTextField.text, !text.isEmpty {
            self.getAddress(address: text) { [weak self] searches in
                DispatchQueue.main.async {
                    self?.searches = searches.suffix(5).reversed()
                    self?.destinationTableView.isHidden = false
                    self?.destinationTableView.reloadData()
                }
            }
        }
    }
    
    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.isAuthorized = true
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.isAuthorized = true
                    }
                }
            default: return
            }
        }
    }
    
    func dispatchNotification() {
        let identifier = "deviation-in-route-notification"
        let title = "Going out of route"
        let body = "you are going out of the selected route"
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
        
    }
    
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func getAddress(address: String, completion: @escaping (([MKMapItem]) -> Void)) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _Arg in
            guard let response = response else {
                return
            }
            completion(response.mapItems)
            print(response)
        }
    }
    
    func createPalyLineFromSourceToDestination(sourceCord: CLLocationCoordinate2D, destinationCord: CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCord)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCord)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { response, error in
            guard let response = response else {
                if error != nil {
                    print("something went wrong")
                }
                return
            }
            let route = response.routes[0]
            self.route = route
            let destinationPin = MKPointAnnotation()
            destinationPin.coordinate = destinationCord
            self.mapView.addAnnotation(destinationPin)
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
            self.getRouteSteps(route: route)
        }
    }
    
    func getRouteSteps(route: MKRoute) {
        for monitoredRegion in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: monitoredRegion)
        }
        let steps = route.steps
        self.steps = steps
        for i in 0..<steps.count {
            let step = steps[i]
            let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
            locationManager.startMonitoring(for: region)
            print(step.polyline.coordinate)
        }
        
        stepCounter += 1
    }
}


extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = destinationTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = searches[indexPath.row].placemark
        cell.textLabel?.text = cellData.name
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        destinationCoordinate = self.searches[indexPath.row].placemark.coordinate
        endLocationTextField.text = self.searches[indexPath.row].name
        sourceCoordinate = locationManager.location?.coordinate
        if sourceCoordinate != nil && destinationCoordinate != nil {
            showMapRoute = true
            createPalyLineFromSourceToDestination(sourceCord: sourceCoordinate!, destinationCord: destinationCoordinate!)
        }
        self.destinationTableView.isHidden = true
        //notify
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isOnRoute {
            showAlert(message: "user moved out of route", viewController: self)
            self.dispatchNotification()
        }
        if !showMapRoute {
            if let location = locations.first {
                render(location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        isOnRoute = false
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        isOnRoute = true
        stepCounter += 1
        if stepCounter < steps.count {
            
        } else {
            //arrived at destination
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .blue
        return render
    }
}

