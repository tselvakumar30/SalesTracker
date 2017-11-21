import UIKit
import PopupDialog
import AFNetworking
import NVActivityIndicatorView
import CoreLocation


class ShopsAssignedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate {

    @IBOutlet var tableViewAssignments: UITableView!
    var arrayShopList = NSMutableArray()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var textFieldTo: UITextField!
    @IBOutlet var textFieldFrom: UITextField!
    var datePickerview = UIDatePicker()
    var strFromDate = String()
    var strToDate = String()
    var nTextFieldTag = Int()
    var activity:NVActivityIndicatorView!
    var dUserCurrentLatitude:Double = 0.0
    var dUserCurrentLongitude:Double = 0.0
    var locationManager:CLLocationManager!



    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeTableviewUI()
        determineMyCurrentLocation()

        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textFieldFrom.inputAccessoryView = doneToolbar
        textFieldTo.inputAccessoryView = doneToolbar
        
        setLoadingIndicator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }

    
    @objc func doneButtonAction(){
        textFieldFrom.resignFirstResponder()
        textFieldTo.resignFirstResponder()
        callWebservice()
    }
    override func viewWillAppear(_ animated: Bool) {
        textFieldTo.text = dateFormatterString(date: NSDate())
        textFieldFrom.text = dateFormatterString(date: NSDate())
        callWebservice()
    }
    func callWebservice(){
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        parameter.setValue(textFieldFrom.text, forKey: "from_date")
        parameter.setValue(textFieldTo.text, forKey: "to_date")
        GetShopsAssigned(params: parameter)
    }
    
    func dateFormatterString(date:NSDate)->String{
        var returnString:String = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        returnString = formatter.string(from: date as Date)
        return returnString
    }
    
    func initializeTableviewUI(){
        self.tableViewAssignments.register(UINib(nibName: "AssignmentsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AssignmentsTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Tableview Delegate Methods -
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arrayShopList.count
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
        return 5
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.view.frame.height/3.3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentsTableViewCell") as! AssignmentsTableViewCell!
        Cell?.labelShopName.text = (arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "shopname") as? String
        Cell?.labelStreetName.text = (arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "shopaddress") as? String
        
        Cell?.SwitchLocation.isHidden = true
        
        if let arrayImageUrl:NSArray = (arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "images") as? NSArray{
            if arrayImageUrl.count > 0{
                if let sImageUrl:String = (arrayImageUrl[0] as AnyObject).value(forKey: "thumb_image") as? String{
                    var sImage:String = ""
                    sImage = ApiString().baseUrl + sImageUrl
                    let Url:URL = URL(string: sImage)!
                    Cell?.imageViewShops.sd_setImage(with: Url, completed: nil)
                }
            }
        }
        Cell?.buttonMap.tag = (indexPath as NSIndexPath).section
        Cell?.buttonCall.tag = (indexPath as NSIndexPath).section
        Cell?.buttonMap.addTarget(self, action: #selector(self.buttonMap(sender:)), for: .touchUpInside)
        Cell?.buttonCall.addTarget(self, action: #selector(self.buttonCall(sender:)), for: .touchUpInside)

        return Cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewAssignments.deselectRow(at: indexPath, animated: false)
        let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"SingleShopViewController") as! SingleShopViewController
        var dictionary = NSDictionary()
        if let dictPassDetails:NSDictionary = arrayShopList[(indexPath as NSIndexPath).section-2] as? NSDictionary{
            dictionary = dictPassDetails
        }
        nextViewController.dictionaryShopDetails = dictionary
        UserDefaults.standard.setValue(dictionary, forKey: "CURRENTSHOPDETAILS")
        let dDestinationLatitude:Double = Double(((arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "latitude") as? String)!)!
        let dDestinationLongitude:Double = Double(((arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "longitude") as? String)!)!
        var distance = Float()
        if dDestinationLatitude == 0.0{
            let dDestinationLatitude1:Double = Double(((arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "latitude2") as? String)!)!
            let dDestinationLongitude1:Double = Double(((arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "longitude2") as? String)!)!
            distance = self.kilometersfromPlace(fromLatitude: dUserCurrentLatitude, fromLongitude: dUserCurrentLongitude, toLatitude: dDestinationLatitude1, toLongitude: dDestinationLongitude1)
        }else{
            distance = self.kilometersfromPlace(fromLatitude: dUserCurrentLatitude, fromLongitude: dUserCurrentLongitude, toLatitude: dDestinationLatitude, toLongitude: dDestinationLongitude)
        }
        if distance <= 0.5{
            UserDefaults.standard.setValue(false, forKey: "SalesManDistance")
        }else{
            UserDefaults.standard.setValue(true, forKey: "SalesManDistance")
        }

        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    //MARK:- TextField Delegates
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        textField.inputView = datePickerview
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if textField == self.textFieldFrom{
            nTextFieldTag = 1
            datePickerview.setDate(formatter.date(from: textFieldFrom.text!)!, animated: false)
            datePickerview.datePickerMode = UIDatePickerMode.date
            datePickerview.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        }else if textField == self.textFieldTo{
            nTextFieldTag = 2
            datePickerview.setDate(formatter.date(from: textFieldTo.text!)!, animated: false)
            datePickerview.datePickerMode = UIDatePickerMode.date
            datePickerview.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        }
    
        return true
    }
    
    @IBAction func buttonFrom(_ sender: Any)
    {
        self.textFieldFrom.becomeFirstResponder()
    }

    @IBAction func buttonTo(_ sender: Any)
    {
        self.textFieldTo.becomeFirstResponder()
    }
    
    
    //MARK:- DatePicker
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        if nTextFieldTag == 1{
            textFieldFrom.text = dateFormatterString(date: sender.date as NSDate)
        }else{
            textFieldTo.text = dateFormatterString(date: sender.date as NSDate)
        }
    }
    
    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
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


    //MARK:- Webservices
    func GetShopsAssigned(params:NSMutableDictionary)
    {
        startLoading()
        self.arrayShopList.removeAllObjects()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().shopsAssignedDate) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "results") as? NSArray{
                        self.arrayShopList.addObjects(from: arrayResults as! [Any])
                        self.tableViewAssignments.reloadData()
                    }
                    self.stopLoading()
                }else{
                    self.tableViewAssignments.reloadData()
                    self.stopLoading()
                    if let Msg:String = (responseDictionary).value(forKey: "msg") as? String{
                        
                        self.popupAlert(Title: "Information", msg: Msg)
                    }
                }
            }
        }, failure: { (operation, error) -> Void in
            self.stopLoading()
            self.tableViewAssignments.reloadData()
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
    


}
