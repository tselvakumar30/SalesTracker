import UIKit
import GoogleMaps
import GooglePlaces



class MapViewController: UIViewController {

    @IBOutlet var viewMapView: UIView!
    var doubleLatitude = Double()
    var doubleLongitude = Double()
    var stringMapTitle = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: doubleLatitude,
                                              longitude:doubleLongitude,
                                              zoom:15)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: viewMapView.frame.width, height: viewMapView.frame.height), camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: doubleLatitude, longitude: doubleLongitude)
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.icon = imageFiles().imageMarker
        marker.map = mapView
        marker.title = stringMapTitle
        viewMapView.addSubview(mapView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }


}
