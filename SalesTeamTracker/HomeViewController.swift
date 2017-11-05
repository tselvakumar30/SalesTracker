import UIKit
import CoreLocation
import PopupDialog
import AFNetworking
import NVActivityIndicatorView


class HomeViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate  {

    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var tableViewAssignMent: UITableView!
    @IBOutlet var buttonAttendance: UIButton!
    var arrayShopList = NSMutableArray()
    var duplicateArray = NSMutableArray()
    var textField = UITextField()
    var locationManager:CLLocationManager!
    var dUserCurrentLatitude:Double = 0.0
    var dUserCurrentLongitude:Double = 0.0
    var activity:NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeTableviewUI()
        determineMyCurrentLocation()
    }
    
    func addArrayData(){
        let param1 = NSMutableDictionary()
        let param2 = NSMutableDictionary()
        
        param1.setValue("PetBuddy Products", forKey: "Shop_Name")
        param2.setValue("DIGIIQ Limited", forKey: "Shop_Name")
        arrayShopList.add(param1)
        arrayShopList.add(param2)
        duplicateArray.add(param1)
        duplicateArray.add(param2)
        
        if buttonAttendance.isHidden{
            tableViewAssignMent.frame = CGRect(x: tableViewAssignMent.frame.origin.x, y: tableViewAssignMent.frame.origin.y, width: tableViewAssignMent.frame.width, height: buttonAttendance.frame.origin.y+(buttonAttendance.frame.height/2))
        }else{
            tableViewAssignMent.frame = CGRect(x: tableViewAssignMent.frame.origin.x, y: tableViewAssignMent.frame.origin.y, width: tableViewAssignMent.frame.width, height: tableViewAssignMent.frame.height - buttonAttendance.frame.height)
        }

    }
    
    func initializeTableviewUI(){
        setLoadingIndicator()
        addArrayData()
        self.tableViewAssignMent.register(UINib(nibName: "AssignmentProgressTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AssignmentProgressTableViewCell")
        self.tableViewAssignMent.register(UINib(nibName: "AssignmentSearchTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AssignmentSearchTableViewCell")
        self.tableViewAssignMent.register(UINib(nibName: "AssignmentsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AssignmentsTableViewCell")
        tableViewAssignMent.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonAttendance(_ sender: Any)
    {
        
    }
    
    
    //MARK: - Tableview Delegate Methods -
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arrayShopList.count + 2
    }
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor.clear
        return viewHeader
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor.clear
        return viewHeader
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0{
            return self.view.frame.height/2.4
        }else if (indexPath as NSIndexPath).section == 1 {
            return self.view.frame.height/9.5
        }else{
            return self.view.frame.height/3.3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath as NSIndexPath).section == 0 {
            let Cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentProgressTableViewCell") as! AssignmentProgressTableViewCell!
            Cell?.labelName.text = "Jeyavijay"
            Cell?.labelDesignation.text = "iOS Developer"
            Cell?.labelAddress.text = "Coimbatore VJ Business Centre "
            Cell?.labelProgress.text = "10%"
            Cell?.sliderProgress.value = 0.3
            return Cell!
        }else if (indexPath as NSIndexPath).section == 1 {
            let Cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentSearchTableViewCell") as! AssignmentSearchTableViewCell!
            textField = (Cell?.textFieldSearch)!
            Cell?.textFieldSearch.delegate = self
            Cell?.textFieldSearch.tag = 1
            Cell?.buttonSearch.addTarget(self, action: #selector(self.buttonSearch(sender:)), for: .touchUpInside)
            textField = (Cell?.textFieldSearch)!
            return Cell!
        }else{
            let Cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentsTableViewCell") as! AssignmentsTableViewCell!
            Cell?.labelShopName.text = (arrayShopList[(indexPath as NSIndexPath).section-2] as AnyObject).value(forKey: "Shop_Name") as? String
            Cell?.labelStreetName.text = "viveganandar Street"
            Cell?.labelCity.text = "Coimbatore VJ Business Centre "
            Cell?.SwitchLocation.tag = (indexPath as NSIndexPath).section - 2
            Cell?.SwitchLocation.addTarget(self, action: #selector(self.buttonSwitch(sender:)), for: .valueChanged)
            Cell?.buttonMap.addTarget(self, action: #selector(self.buttonMap), for: .touchUpInside)
            Cell?.buttonCall.addTarget(self, action: #selector(self.buttonCall), for: .touchUpInside)
            return Cell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewAssignMent.deselectRow(at: indexPath, animated: false)
        let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"SingleShopViewController") as! SingleShopViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func buttonSwitch(sender:UISwitch){

        let dDestinationLatitude:Double = 10.9987
        let dDestinationLongitude:Double = 77.0320
        
        let distance:Float = self.kilometersfromPlace(fromLatitude: dUserCurrentLatitude, fromLongitude: dUserCurrentLongitude, toLatitude: dDestinationLatitude, toLongitude: dDestinationLongitude)
        print(distance)
        
        if distance <= 0.5{
          // Call Api
        }else{
            popupAlert(Title: "Information", msg: "You are far away from the shop location")
        }
    }
    
    @objc func buttonMap(){
        let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"MapViewController") as! MapViewController
        nextViewController.doubleLatitude = 41.887
        nextViewController.doubleLongitude = -87.622
        nextViewController.stringMapTitle = "Title Map"
            self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @objc func buttonCall()
    {
        if let url = URL(string: "tel://\(8973576442)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    @objc func buttonSearch(sender:UISwitch){
        textField.resignFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        searchAutocompleteEntriesWithSubstring(substring: textField.text!)
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        arrayShopList.removeAllObjects()
        if substring == ""{
            arrayShopList.addObjects(from: duplicateArray as [AnyObject])
        }else{
            for i in 0 ..< duplicateArray.count {
                let myString:NSString = (duplicateArray[i] as AnyObject).value(forKey: "Shop_Name") as! NSString
                let substringRange:NSRange = myString.range(of: substring, options: .caseInsensitive)
                if (substringRange.location  != NSNotFound)
                {
                    let param = NSMutableDictionary()
                    let str:NSString = (duplicateArray[i] as AnyObject).value(forKey: "Shop_Name") as! NSString
                    param.setValue(str, forKey: "Shop_Name")
                    arrayShopList.add(param)
                }
            }
        }
        tableViewAssignMent.reloadData()
    }

    
    // CoreLocation - Get Location
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        self.locationManager?.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        dUserCurrentLatitude = userLocation.coordinate.latitude
        dUserCurrentLongitude = userLocation.coordinate.longitude
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    func kilometersfromPlace(fromLatitude: Double,fromLongitude: Double, toLatitude: Double,toLongitude: Double) -> Float {
        let userloc = CLLocation(latitude: fromLatitude, longitude: fromLongitude)
        let dest = CLLocation(latitude: toLatitude, longitude: toLongitude)
        let dist:CLLocationDistance = (userloc.distance(from: dest) / 1000)
        let distance = "\(dist)"
        return Float(distance) ?? 0.0
    }
    
    //MARK:- Activity Indicator View
    func setLoadingIndicator()
    {
        activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activity.color = AppColors().appBlueColor
        activity.type = NVActivityIndicatorType.ballScaleMultiple
        activity.startAnimating()
        activity.center = view.center
    }
    func startLoading()
    {
        view.isUserInteractionEnabled = false
        self.view.addSubview(activity)
    }
    
    func stopLoading(){
        activity.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }
    
    //MARK:- Alert Class
    
    func popupAlert(Title:String,msg:String)
    {
        let popup = PopupDialog(title: Title, message: msg, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
        }
        let buttonOk = DefaultButton(title: "OK")
        {
        }
        buttonOk.buttonColor = UIColor.red
        buttonOk.titleColor = UIColor.white
        popup.addButtons([buttonOk])
        self.present(popup, animated: true, completion: nil)
    }
    
    
    
}
