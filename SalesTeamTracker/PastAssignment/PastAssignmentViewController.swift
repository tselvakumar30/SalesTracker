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
        initializeUI()
        determineMyCurrentLocation()

        
    }
    
    func initializeUI(){
        pieChartView.delegate = self
        let months = ["Income", "Expense", "Wallet", "Bank"]
        let unitsSold = [65.0, 45.13, 78.67, 85.52]
        setChart(dataPoints: months, values: unitsSold)
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
        segmentController.borderWidth = 1.0
        segmentController.borderColor = AppColors().appBlueColor
        segmentController.addTarget(self, action: #selector(self.listDataChangeValues(_:)), for: .valueChanged)
        view.addSubview(segmentController)
        viewList.isHidden = true
        addArrayData()
        self.tableViewList.register(UINib(nibName: "AssignmentsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AssignmentsTableViewCell")
        tableViewList.reloadData()
    }
    
    func addArrayData(){
        let param1 = NSMutableDictionary()
        let param2 = NSMutableDictionary()
        
        param1.setValue("PetBuddy Products", forKey: "Shop_Name")
        param2.setValue("DIGIIQ Limited", forKey: "Shop_Name")
        arrayShopList.add(param1)
        arrayShopList.add(param2)
        arrayShopList.add(param1)
        arrayShopList.add(param2)
        
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
        
        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
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
            Cell?.labelShopName.text = (arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "Shop_Name") as? String
            Cell?.labelStreetName.text = "viveganandar Street"
            Cell?.labelCity.text = "Coimbatore VJ Business Centre "
            Cell?.SwitchLocation.tag = (indexPath as NSIndexPath).section
            Cell?.SwitchLocation.addTarget(self, action: #selector(self.buttonSwitch(sender:)), for: .valueChanged)
            Cell?.buttonMap.addTarget(self, action: #selector(self.buttonMap), for: .touchUpInside)
            Cell?.buttonCall.addTarget(self, action: #selector(self.buttonCall), for: .touchUpInside)

            return Cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewList.deselectRow(at: indexPath, animated: false)
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
