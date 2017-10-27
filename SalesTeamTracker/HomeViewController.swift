import UIKit

class HomeViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate  {

    @IBOutlet var tableViewAssignMent: UITableView!
    @IBOutlet var buttonAttendance: UIButton!
    var arrayShopList = NSMutableArray()
    var duplicateArray = NSMutableArray()

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
        duplicateArray.add(param1)
        duplicateArray.add(param2)

    }
    
    func initializeTableviewUI(){
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
        return 10
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
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
            return self.view.frame.height/4.7
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
            Cell?.textFieldSearch.delegate = self
            Cell?.textFieldSearch.tag = 1
            
            return Cell!
        }else{
            let Cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentsTableViewCell") as! AssignmentsTableViewCell!
            Cell?.labelShopName.text = (arrayShopList[(indexPath as NSIndexPath).section-2] as AnyObject).value(forKey: "Shop_Name") as? String
            Cell?.labelStreetName.text = "viveganandar Street"
            Cell?.labelCity.text = "Coimbatore VJ Business Centre "
            Cell?.SwitchLocation.tag = (indexPath as NSIndexPath).section - 2
            Cell?.SwitchLocation.addTarget(self, action: #selector(self.buttonSwitch(sender:)), for: .valueChanged)
            return Cell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewAssignMent.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func buttonSwitch(sender:UISwitch){
    
        print(sender.tag)

    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
//            let currentText = textField.text ?? ""
//            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
//            let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//                    searchAutocompleteEntriesWithSubstring(substring: substring, tField: textField)
//        return true
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
  //      let substring = .replacingCharacters(in: range, with: string)
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

}
