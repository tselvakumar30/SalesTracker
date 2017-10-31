import UIKit
import Charts
import BetterSegmentedControl

class PastAssignmentViewController: UIViewController,ChartViewDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var pieChartView: PieChartView!
  
    @IBOutlet var tableViewList: UITableView!
    @IBOutlet var viewList: UIView!
    @IBOutlet var segmentController: BetterSegmentedControl!
    var arrayShopList = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewList.isHidden = false
        initializeUI()
        
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
        
            return Cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewList.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func buttonSwitch(sender:UISwitch){
        print(sender.tag)
    }



}
