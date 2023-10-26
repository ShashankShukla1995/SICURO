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
    var searches : [MKMapItem] = []
    var sourceCoordinate: CLLocationCoordinate2D? = nil
    var destinationCoordinate: CLLocationCoordinate2D? = nil
    var isDestination : Bool = false
    let sourceTableView :UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let destinationTableView :UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
//    let searchVC = UISearchController(searchResultsController: ResultsViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        view.addSubview(sourceTableView)
        mapView.delegate = self
        sourceTableView.delegate = self
        sourceTableView.dataSource = self
        sourceTableView.isHidden = true
        
        destinationTableView.delegate = self
        destinationTableView.dataSource = self
        destinationTableView.isHidden = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        var tableY = startLocationTextField.frame.origin.y+startLocationTextField.frame.height+5
        sourceTableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
        tableY = endLocationTextField.frame.origin.y+endLocationTextField.frame.height+5
        destinationTableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
        startLocationTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        endLocationTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

    }
    
    @IBAction func didTapSource(_ sender: Any) {
        self.isDestination = false
    }
    
    @IBAction func didTapDestination(_ sender: Any) {
        self.isDestination = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = startLocationTextField.text, !text.isEmpty {
            self.getAddress(address: text) { [weak self] searches in
                DispatchQueue.main.async {
                    self?.searches = searches.suffix(5).reversed()
                    if self?.isDestination == true {
                        self?.destinationTableView.isHidden = false
                    } else {
                        self?.sourceTableView.isHidden = false
                    }
                    self?.sourceTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = isDestination ? destinationTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) : sourceTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = searches[indexPath.row].placemark
        cell.textLabel?.text = cellData.name
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !isDestination {
            sourceCoordinate = self.searches[indexPath.row].placemark.coordinate
//
        } else {
            destinationCoordinate = self.searches[indexPath.row].placemark.coordinate
        }
        if sourceCoordinate != nil && destinationCoordinate != nil {
            createPalyLineFromSourceToDestination(sourceCord: sourceCoordinate!, destinationCord: destinationCoordinate!)
        }
        self.destinationTableView.isHidden = true
        self.sourceTableView.isHidden = true
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
    
    func getAddress(address: String, completion: @escaping (([MKMapItem]) -> Void)) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = startLocationTextField.text
//        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _Arg in
            guard let response = response else {
                return
            }
            completion(response.mapItems)
            print(response)
        }
//        let geoCoder = CLGeocoder()
//        geoCoder.geocodeAddressString(address) { placemarks, error in
//            guard let placemarks = placemarks, error == nil else {
//                print("no location found")
//                completion([])
//                return
//            }
//            let models: [Location] = placemarks.compactMap({ places in
//                var name = ""
//                if let locationName = places.addressDictionary?["Name"] as? String {
//                    name += locationName
//                }
//                if let region = places.administrativeArea {
//                    name += ", \(region)"
//                }
//                if let locality = places.locality {
//                    name += ", \(locality)"
//                }
//                if let country = places.country {
//                    name += ", \(country)"
//                }
//                let result = Location(title: name, coordinate: places.location?.coordinate)
//                return result
//            })
//            completion(models)
//        }
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
