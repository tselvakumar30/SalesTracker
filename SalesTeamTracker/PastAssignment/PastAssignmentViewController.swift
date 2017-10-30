import UIKit
import Charts
import BetterSegmentedControl

class PastAssignmentViewController: UIViewController,ChartViewDelegate {

    @IBOutlet var pieChartView: PieChartView!
  
    @IBOutlet var segmentController: BetterSegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
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
            index: 0,
            options: [.backgroundColor(UIColor.white),
                      .titleColor(AppColors().appBlueColor),.cornerRadius((self.view.frame.height)/29),.indicatorViewBackgroundColor(AppColors().appBlueColor),
                      .indicatorViewBackgroundColor(AppColors().appBlueColor),
                      .selectedTitleColor(.white),
                      .titleFont(UIFont(name: "HelveticaNeue", size: 14.0)!),
                      .selectedTitleFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!)]
        )
        segmentController.borderWidth = 1.0
        segmentController.borderColor = AppColors().appBlueColor
        view.addSubview(segmentController)

        


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
        
        let d = Description()
        d.text = " "
        pieChartView.chartDescription = d
        pieChartView.centerText = " "
        pieChartView.holeRadiusPercent = 0.2
        pieChartView.transparentCircleColor = UIColor.clear
        pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }

}
