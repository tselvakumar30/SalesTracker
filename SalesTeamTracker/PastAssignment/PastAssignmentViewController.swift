import UIKit
import Charts
import BetterSegmentedControl
import CoreLocation
import PopupDialog
import AFNetworking
import NVActivityIndicatorView


class PastAssignmentViewController: UIViewController,ChartViewDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    
    @IBOutlet var pieChartView: PieChartView!
    
    @IBOutlet var tableViewList: UITableView!
    @IBOutlet var viewList: UIView!
    @IBOutlet var segmentController: BetterSegmentedControl!
    var arrayShopList = NSMutableArray()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var locationManager:CLLocationManager!
    var dUserCurrentLatitude:Double = 0.0
    var dUserCurrentLongitude:Double = 0.0
    var activity:NVActivityIndicatorView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewList.isHidden = false
        setLoadingIndicator()
        initializeUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        determineMyCurrentLocation()
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        GetPastAssignments(params: parameter)
    }
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func initializeUI(){
        pieChartView.delegate = self
        segmentController = BetterSegmentedControl(
            frame: CGRect(x: self.segmentController.frame.origin.x, y: self.segmentController.frame.origin.y, width: self.segmentController.frame.width, height: self.segmentController.frame.height),
            titles: ["List","Data"],
            index: 1,
            options: [.backgroundColor(UIColor.white),
                      .titleColor(AppColors().appBlueColor),.cornerRadius((self.view.frame.height)/29),.indicatorViewBackgroundColor(AppColors().appBlueColor),
                      .indicatorViewBackgroundColor(AppColors().appBlueColor),
                      .selectedTitleColor(.white),
                      .titleFont(UIFont(name: "HelveticaNeue", size: 14.0)!),
                      .selectedTitleFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!)]
        )
        segmentController.layer.cornerRadius = segmentController.frame.height/2
        segmentController.borderWidth = 1.0
        segmentController.borderColor = AppColors().appBlueColor
        segmentController.addTarget(self, action: #selector(self.listDataChangeValues(_:)), for: .valueChanged)
        view.addSubview(segmentController)
        viewList.isHidden = true
        self.tableViewList.register(UINib(nibName: "AssignmentsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AssignmentsTableViewCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- ChartViewDelegate
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight){
        
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var entries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = dataPoints[index]
            entries.append( entry)
        }
        
        // 3. chart setup
        let set = PieChartDataSet( values: entries, label: "")
        set.entryLabelFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        set.valueFont = NSUIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        
        var colors: [UIColor] = []
        
        let color = UIColor(red: CGFloat(30.0/255.0), green: CGFloat(120.0/255), blue: CGFloat(30.0/255), alpha: 1)
        let color1 = UIColor(red: CGFloat(180.0/255), green: CGFloat(10.0/255), blue: CGFloat(10.0/255), alpha: 1)
        
        colors.append(color)
        colors.append(color1)
        
        set.colors = colors
        let data = PieChartData(dataSet: set)
        pieChartView.data = data
        pieChartView.noDataText = "No data available"
        pieChartView.isUserInteractionEnabled = true
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "Assignment Data" as String)
        attributedText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)], range: NSRange(location: 0, length: 15))
        
        
        let d = Description()
        d.text = " "
        pieChartView.chartDescription = d
        pieChartView.centerAttributedText = attributedText
        pieChartView.holeRadiusPercent = 0.58
        pieChartView.transparentCircleColor = UIColor.clear
        pieChartView.animate(xAxisDuration: 1.2, easingOption: .easeInCirc)
    }
    
    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - Action handlers
    @objc func listDataChangeValues(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            viewList.isHidden = false
        }
        else {
            viewList.isHidden = true
        }
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
        
        if let sStatus:String = (arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "status") as? String{
            if sStatus == "0"{
                //Cell?.SwitchLocation.isOn = false
            }else{
                //Cell?.SwitchLocation.isOn = true
            }
        }
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
        Cell?.SwitchLocation.isHidden = true
        return Cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewList.deselectRow(at: indexPath, animated: false)
            let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"SingleShopViewController") as! SingleShopViewController
            var dictionary = NSDictionary()
            if let dictPassDetails:NSDictionary = arrayShopList[(indexPath as NSIndexPath).section] as? NSDictionary{
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
    
    //MARK:- Webservices
    func GetPastAssignments(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().pastAssignmentUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "results") as? NSArray{
                        self.arrayShopList.removeAllObjects()
                        self.arrayShopList.addObjects(from: arrayResults as! [Any])
                        if let nCompleted:Float = responseDictionary.value(forKey: "shop_assignment_completed") as? Float{
                            if let nTotalCount:Float = responseDictionary.value(forKey: "shopcount") as? Float{
                                let fCompletedProgress:Float = roundf(nCompleted/nTotalCount * 100)
                                let fIncompletedProgress:Float = 100 - fCompletedProgress
                                let status = ["Completed", "In Completed"]
                                let completed = [Double(fCompletedProgress), Double(fIncompletedProgress)]
                                self.setChart(dataPoints: status, values: completed)
                            }
                            
                        }
                        
                        self.tableViewList.reloadData()
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
