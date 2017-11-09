import UIKit
import XLPagerTabStrip


class MessageViewController: UIViewController,IndicatorInfoProvider {

    @IBOutlet var viewTextField: UIView!
    @IBOutlet var textFieldMessage: UITextField!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initializeUI()

    }

    func initializeUI(){
        viewTextField.layer.cornerRadius = textFieldMessage.frame.height/2.6
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Comments")
    }

}
