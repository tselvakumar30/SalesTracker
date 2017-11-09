import UIKit
import XLPagerTabStrip

class ActivityViewController: UIViewController,IndicatorInfoProvider {

    @IBOutlet var viewDemo: UIView!
    @IBOutlet var viewSamples: UIView!
    @IBOutlet var viewPromotions: UIView!
    
    @IBOutlet var switchOrders: UISwitch!
    @IBOutlet var switchStocks: UISwitch!
    @IBOutlet var switchPromotions: UISwitch!
    @IBOutlet var labelOrder: UILabel!
    @IBOutlet var labelStock: UILabel!
    @IBOutlet var labelPromotions: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Activity")
    }
    
    

}
