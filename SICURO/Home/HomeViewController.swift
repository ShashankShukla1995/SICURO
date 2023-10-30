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

class PinAnatotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    
}

class HomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var startLocationTextField: UITextField!
    @IBOutlet weak var endLocationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bookCabButton: UIButton!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    let locationManager = CLLocationManager()
    var locations = [Location]()
    var searches : [MKMapItem] = []
    var sourceCoordinate: CLLocationCoordinate2D? = nil
    var destinationCoordinate: CLLocationCoordinate2D? = nil
    var steps:[MKRoute.Step] = []
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
        view.addSubview(destinationTableView)
        mapView.delegate = self
        sourceTableView.delegate = self
        sourceTableView.dataSource = self
        sourceTableView.isHidden = true
        
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
        var tableY = startLocationTextField.frame.origin.y+startLocationTextField.frame.height+5
        sourceTableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
        tableY = endLocationTextField.frame.origin.y+endLocationTextField.frame.height+5
        destinationTableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
        startLocationTextField.addTarget(self, action: #selector(self.startLocationTextFieldDidChange(_:)), for: .editingChanged)
        endLocationTextField.addTarget(self, action: #selector(self.endLocationTextFieldDidChange(_:)), for: .editingChanged)

    }
    
    @IBAction func didTapSource(_ sender: Any) {
    }
    
    @IBAction func didTapDestination(_ sender: Any) {
    }
    @IBAction func didTapAddContacts(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContactsViewController")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc func startLocationTextFieldDidChange(_ textField: UITextField) {
        if let text = startLocationTextField.text, !text.isEmpty {
            self.getAddress(address: text) { [weak self] searches in
                DispatchQueue.main.async {
                    self?.searches = searches.suffix(5).reversed()
                    self?.sourceTableView.isHidden = false
                    self?.sourceTableView.reloadData()
                }
            }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView == destinationTableView ? destinationTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) : sourceTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = searches[indexPath.row].placemark
        cell.textLabel?.text = cellData.name
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == sourceTableView {
            sourceCoordinate = self.searches[indexPath.row].placemark.coordinate
            startLocationTextField.text = self.searches[indexPath.row].name
//
        } else {
            destinationCoordinate = self.searches[indexPath.row].placemark.coordinate
            endLocationTextField.text = self.searches[indexPath.row].name
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
            render(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
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
            self.steps = route.steps
            let sourcePin = PinAnatotation(title: "", subtitle: "", coordinate: sourceCord)
            let destinationPin = PinAnatotation(title: "", subtitle: "", coordinate: destinationCord)
            self.mapView.addAnnotation(sourcePin)
            self.mapView.addAnnotation(destinationPin)
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .blue
        return render
    }
    

}
