import UIKit

class ShopsAssignedViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet var tableViewAssignments: UITableView!
    var arrayShopList = NSMutableArray()
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var textFieldTo: UITextField!
    @IBOutlet var textFieldFrom: UITextField!
    var datePickerview = UIDatePicker()
    var strFromDate = String()
    var strToDate = String()
    var nTextFieldTag = Int()


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeTableviewUI()

    }
    
    
    func addArrayData(){
        let param1 = NSMutableDictionary()
        let param2 = NSMutableDictionary()
        
        param1.setValue("PetBuddy Products", forKey: "Shop_Name")
        param2.setValue("DIGIIQ Limited", forKey: "Shop_Name")
        arrayShopList.add(param1)
        arrayShopList.add(param2)
    }
    
    func initializeTableviewUI(){
        addArrayData()
        self.tableViewAssignments.register(UINib(nibName: "AssignmentsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AssignmentsTableViewCell")
        tableViewAssignments.reloadData()
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
        Cell?.labelShopName.text = (arrayShopList[(indexPath as NSIndexPath).section] as AnyObject).value(forKey: "Shop_Name") as? String
        Cell?.labelStreetName.text = "viveganandar Street"
        Cell?.labelCity.text = "Coimbatore VJ Business Centre "
        Cell?.SwitchLocation.isHidden = true
        Cell?.buttonMap.addTarget(self, action: #selector(self.buttonMap), for: .touchUpInside)
        Cell?.buttonCall.addTarget(self, action: #selector(self.buttonCall), for: .touchUpInside)

        return Cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewAssignments.deselectRow(at: indexPath, animated: false)
    }
    
    //MARK:- TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        var datePickerView1 = UIDatePicker()
        datePickerview = datePickerView1
        textField.inputView = datePickerview
        if textField == self.textFieldFrom{
            nTextFieldTag = 1
            datePickerview.datePickerMode = UIDatePickerMode.date
            datePickerview.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        }else if textField == self.textFieldTo{
            nTextFieldTag = 2
            datePickerview.datePickerMode = UIDatePickerMode.date
            datePickerview.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        }
    
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
        
//        let dateFormatter1 = DateFormatter()
//        dateFormatter1.dateFormat = "MM/dd/yyyy" //Your date format
//        let date = dateFormatter1.date(from: "01-01-2017") //according to date format your date string
        let now = Date()
        let calendar = NSCalendar.current
        let nTime:Int = calendar.timeZone.secondsFromGMT(for: now)
        let oneDayAgoInterval:TimeInterval = TimeInterval((-1 * 24 * 60 * 60)+nTime)
        let currentDayInterval:TimeInterval = TimeInterval((1 * 24 * 60 * 60)+nTime)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        dateFormatter1.dateFormat = "MM/dd/yyyy"

        if nTextFieldTag == 1{
            let oneDaysAgo: Date? = now.addingTimeInterval(oneDayAgoInterval)
            datePickerview.maximumDate = oneDaysAgo
            strFromDate = dateFormatter.string(from: sender.date)
            textFieldFrom.text = strFromDate
        }else{
            let oneDaysAgo: Date? = now.addingTimeInterval(currentDayInterval)
            datePickerview.minimumDate = oneDaysAgo
            strToDate = dateFormatter1.string(from: sender.date)
            textFieldTo.text = strToDate
        }
    }
    
    
    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
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


    

}
