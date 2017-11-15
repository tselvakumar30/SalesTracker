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
    var nAssignmentStatus:Float = 0
    var nShopCount:Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeTableviewUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableViewAssignMent.frame = CGRect(x: self.tableViewAssignMent.frame.origin.x, y: self.tableViewAssignMent.frame.origin.y, width: self.tableViewAssignMent.frame.width, height: self.view.frame.height - self.tableViewAssignMent.frame.origin.y-10)
        determineMyCurrentLocation()
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        GetAssignments(params: parameter)
    }
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func initializeTableviewUI(){
        setLoadingIndicator()
        //addArrayData()
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
        UpdateAttendence()
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
            Cell?.labelProgress.text = "0%"
            if nShopCount != 0 {
                let sProgress:String = String(roundf(nAssignmentStatus/nShopCount * 100)) + "%"
                let arr = sProgress.components(separatedBy: ".")
                Cell?.labelProgress.text = arr[0] + "%"
            }
            
            Cell?.sliderProgress.maximumValue = nShopCount
            Cell?.sliderProgress.value = nAssignmentStatus
            if let dictDetails:NSDictionary = UserDefaults.standard.value(forKey: "USERDETAILS") as? NSDictionary{
            if let dictUserDetails:NSArray = dictDetails.value(forKey: "user_details") as? NSArray{
                var sFullAddress:String = ""
                if let sStreet:String = (dictUserDetails[0] as AnyObject).value(forKey: "street") as? String{
                    sFullAddress = sFullAddress + sStreet
                }
                if let sCity:String = (dictUserDetails[0] as AnyObject).value(forKey: "city") as? String{
                    if sFullAddress == ""{
                        sFullAddress = sFullAddress + sCity
                    }else{
                        sFullAddress = sFullAddress + ", " + sCity
                    }
                }
                if let sState:String = (dictUserDetails[0] as AnyObject).value(forKey: "state") as? String{
                    if sFullAddress == ""{
                        sFullAddress = sFullAddress + sState
                    }else{
                        sFullAddress = sFullAddress + ", " + sState
                    }
                }
                Cell?.labelAddress.text = sFullAddress
                
                var sFullName:String = ""
                if let sFname:String = (dictUserDetails[0] as AnyObject).value(forKey: "firstname") as? String{
                    sFullName = sFullName + sFname
                }
                if let sLname:String = (dictUserDetails[0] as AnyObject).value(forKey: "lastname") as? String{
                    sFullName = sFullName + " " + sLname
                }
                Cell?.labelName.text = sFullName
                if let sDesignation:String = (dictUserDetails[0] as AnyObject).value(forKey: "designation") as? String{
                    Cell?.labelDesignation.text = sDesignation
                }
                
                if let sImageUrl:String = (dictUserDetails[0] as AnyObject).value(forKey: "thumbimage") as? String{
                    var sImage:String = ""
                    sImage = ApiString().baseUrl + sImageUrl
                    let Url:URL = URL(string: sImage)!
                    Cell?.imageViewSalesProduct.sd_setImage(with: Url, completed: nil)
                }
            }
            }
            
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
            Cell?.SwitchLocation.isOn = false
            Cell?.labelShopName.text = (arrayShopList[(indexPath as NSIndexPath).section-2] as AnyObject).value(forKey: "shopname") as? String
            Cell?.labelStreetName.text = (arrayShopList[(indexPath as NSIndexPath).section-2] as AnyObject).value(forKey: "shopaddress") as? String
            
            if let sStatus:String = (arrayShopList[(indexPath as NSIndexPath).section-2] as AnyObject).value(forKey: "status") as? String{
                if sStatus == "0"{
                    Cell?.SwitchLocation.isOn = false
                }else{
                    Cell?.SwitchLocation.isOn = true
                }
            }
            if let arrayImageUrl:NSArray = (arrayShopList[(indexPath as NSIndexPath).section-2] as AnyObject).value(forKey: "images") as? NSArray{
                if arrayImageUrl.count > 0{
                    if let sImageUrl:String = (arrayImageUrl[0] as AnyObject).value(forKey: "thumb_image") as? String{
                        var sImage:String = ""
                        sImage = ApiString().baseUrl + sImageUrl
                        let Url:URL = URL(string: sImage)!
                        Cell?.imageViewShops.sd_setImage(with: Url, completed: nil)
                    }
                }
            }
            Cell?.SwitchLocation.tag = (indexPath as NSIndexPath).section - 2
            Cell?.buttonMap.tag = (indexPath as NSIndexPath).section - 2
            Cell?.buttonCall.tag = (indexPath as NSIndexPath).section - 2
            Cell?.SwitchLocation.addTarget(self, action: #selector(self.buttonSwitch(sender:)), for: .valueChanged)
            Cell?.buttonMap.addTarget(self, action: #selector(self.buttonMap(sender:)), for: .touchUpInside)
            Cell?.buttonCall.addTarget(self, action: #selector(self.buttonCall(sender:)), for: .touchUpInside)
            return Cell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewAssignMent.deselectRow(at: indexPath, animated: false)
        if !(indexPath.section == 0 && indexPath.section == 1)
        {
            let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"SingleShopViewController") as! SingleShopViewController
            var dictionary = NSDictionary()
            if let dictPassDetails:NSDictionary = arrayShopList[(indexPath as NSIndexPath).section-2] as? NSDictionary{
                dictionary = dictPassDetails
            }
            nextViewController.dictionaryShopDetails = dictionary
            UserDefaults.standard.setValue(dictionary, forKey: "CURRENTSHOPDETAILS")
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    @objc func buttonSwitch(sender:UISwitch){

        let dDestinationLatitude:Double = Double(((arrayShopList[sender.tag] as AnyObject).value(forKey: "latitude") as? String)!)!
        let dDestinationLongitude:Double = Double(((arrayShopList[sender.tag] as AnyObject).value(forKey: "longitude") as? String)!)!
        
        let distance:Float = self.kilometersfromPlace(fromLatitude: dUserCurrentLatitude, fromLongitude: dUserCurrentLongitude, toLatitude: dDestinationLatitude, toLongitude: dDestinationLongitude)
        
        let sAssignmentId:String = ((arrayShopList[sender.tag] as AnyObject).value(forKey: "assignmentid") as? String)!
        let sShopId:String = ((arrayShopList[sender.tag] as AnyObject).value(forKey: "shopid") as? String)!
        
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        parameter.setValue(sAssignmentId, forKey: "assignmentid")
        parameter.setValue(sShopId, forKey: "shopid")
        
        if distance <= 0.5{
            if let sStatus:String = (arrayShopList[sender.tag] as AnyObject).value(forKey: "status") as? String{
                if sStatus == "0"{
                    parameter.setValue("1", forKey: "status")
                }else{
                    parameter.setValue("0", forKey: "status")
                }
            }
            UpdateStatus(params: parameter)
        }else{
            tableViewAssignMent.reloadData()
            popupAlert(Title: "Information", msg: "You are far away from the shop location")
        }
    }
    
    @objc func buttonMap(sender:UIButton){
        let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"MapViewController") as! MapViewController
        nextViewController.doubleLatitude = Double(((arrayShopList[sender.tag] as AnyObject).value(forKey: "latitude") as? String)!)!
        nextViewController.doubleLongitude = Double(((arrayShopList[sender.tag] as AnyObject).value(forKey: "longitude") as? String)!)!
        nextViewController.stringMapTitle = ((arrayShopList[sender.tag] as AnyObject).value(forKey: "shopname") as? String)!
            self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @objc func buttonCall(sender:UIButton)
    {
        let sPhonenumber:String = ((arrayShopList[sender.tag] as AnyObject).value(forKey: "phonenumber") as? String)!
        if let url = URL(string: "tel://\(sPhonenumber)"), UIApplication.shared.canOpenURL(url) {
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
                let myString:NSString = (duplicateArray[i] as AnyObject).value(forKey: "shopname") as! NSString
                let substringRange:NSRange = myString.range(of: substring, options: .caseInsensitive)
                if (substringRange.location  != NSNotFound)
                {
                    arrayShopList.add(duplicateArray[i])
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
    
    //MARK:- Webservices
    func GetAssignments(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().assignmentUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    if let nTotalCount:Float = responseDictionary.value(forKey: "shopcount") as? Float{
                        self.nShopCount = nTotalCount
                    }
                    if let nInCompleted:Float = responseDictionary.value(forKey: "shop_assignment_completed") as? Float{
                        self.nAssignmentStatus = nInCompleted
                    }
                    if let nAttendence:Float = responseDictionary.value(forKey: "attendance_status") as? Float{
                        if nAttendence == 0{
                            self.buttonAttendance.isHidden = false
                            self.tableViewAssignMent.frame = CGRect(x: self.tableViewAssignMent.frame.origin.x, y: self.tableViewAssignMent.frame.origin.y, width: self.tableViewAssignMent.frame.width, height: self.tableViewAssignMent.frame.height - self.buttonAttendance.frame.height)

                        }else{
                            self.buttonAttendance.isHidden = true
                            self.tableViewAssignMent.frame = CGRect(x: self.tableViewAssignMent.frame.origin.x, y: self.tableViewAssignMent.frame.origin.y, width: self.tableViewAssignMent.frame.width, height: self.tableViewAssignMent.frame.height+(self.buttonAttendance.frame.height)/2.3)
                        }
                    }
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "results") as? NSArray{
                        self.arrayShopList.removeAllObjects()
                        self.duplicateArray.removeAllObjects()
                        self.duplicateArray.addObjects(from: arrayResults as! [Any])
                        self.arrayShopList.addObjects(from: arrayResults as! [Any])
                        self.tableViewAssignMent.reloadData()
                    }
                    self.stopLoading()
                }else{
                    self.stopLoading()
                    if let Msg:String = (responseDictionary).value(forKey: "msg") as? String{
                        self.popupAlert(Title: "Information", msg: Msg)
                    }
                }
            }
        }, failure: { (operation, error) -> Void in
            self.stopLoading()
            self.popupAlert(Title: "Information", msg: error.localizedDescription)
        })
    }
    
    func UpdateStatus(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().assignmentUpdateUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    let parameter = NSMutableDictionary()
                    parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
                    self.stopLoading()
                    self.GetAssignments(params: parameter)
                }else{
                    self.stopLoading()
                    if let Msg:String = (responseDictionary).value(forKey: "msg") as? String{
                        self.popupAlert(Title: "Information", msg: Msg)
                    }
                }
            }
        }, failure: { (operation, error) -> Void in
            self.stopLoading()
            self.popupAlert(Title: "Information", msg: error.localizedDescription)
        })
    }
    
    func UpdateAttendence()
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().attendanceUrl) as NSString
        
        let params = NSMutableDictionary()
        params.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    self.buttonAttendance.isHidden = true
                    self.tableViewAssignMent.frame = CGRect(x: self.tableViewAssignMent.frame.origin.x, y: self.tableViewAssignMent.frame.origin.y, width: self.tableViewAssignMent.frame.width, height: self.tableViewAssignMent.frame.height+(self.buttonAttendance.frame.height)/2.3)
                    self.stopLoading()
                }else{
                    self.tableViewAssignMent.frame = CGRect(x: self.tableViewAssignMent.frame.origin.x, y: self.tableViewAssignMent.frame.origin.y, width: self.tableViewAssignMent.frame.width, height: self.tableViewAssignMent.frame.height - self.buttonAttendance.frame.height)

                    self.stopLoading()
                    if let Msg:String = (responseDictionary).value(forKey: "msg") as? String{
                        self.popupAlert(Title: "Information", msg: Msg)
                    }
                }
            }
        }, failure: { (operation, error) -> Void in
            self.stopLoading()
            self.popupAlert(Title: "Information", msg: error.localizedDescription)
        })
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
