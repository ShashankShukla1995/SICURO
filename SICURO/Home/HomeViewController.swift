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

class HomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var startLocationTextField: UITextField!
    @IBOutlet weak var endLocationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bookCabButton: UIButton!
    
    let locationManager = CLLocationManager()
    var locations = [Location]()
    let searchTableView :UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
//    let searchVC = UISearchController(searchResultsController: ResultsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        view.addSubview(searchTableView)
        mapView.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.isHidden = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        let tableY = startLocationTextField.frame.origin.y+startLocationTextField.frame.height+5
        searchTableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
        
        startLocationTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        startLocationTextField.resignFirstResponder()
        if let text = startLocationTextField.text, !text.isEmpty {
            self.getAddress(address: text) { [weak self] locations in
                DispatchQueue.main.async {
                    self?.locations = locations
                    self?.searchTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //notify
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
    func getAddress(address: String, completion: @escaping (([Location]) -> Void)) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { placemarks, error in
            guard let placemarks = placemarks, error == nil else {
                print("no location found")
                completion([])
                return
            }
            let models: [Location] = placemarks.compactMap({ places in
                var name = ""
                if let locationName = places.name {
                    name += locationName
                }
                if let region = places.administrativeArea {
                    name += ", \(region)"
                }
                if let locality = places.locality {
                    name += ", \(locality)"
                }
                if let country = places.country {
                    name += ", \(country)"
                }
                let result = Location(title: "", coordinate: places.location?.coordinate)
                return result
            })
            completion(models)
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
                if let error = error {
                    print("something went wrong")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .blue
        return render
    }
    

}
