import UIKit
import XLPagerTabStrip


class MessageViewController: UIViewController,IndicatorInfoProvider {

    @IBOutlet var tableViewComments: UITableView!
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
    
    
    func getHeightBasedonText(Message:String,textViewSize:CGSize)->CGSize{

        let cellFont: UIFont? = (UIFont(name: "Helvetica", size: 15.0))
        let attrString = NSAttributedString.init(string: Message, attributes: [NSAttributedStringKey.font:cellFont])
        let rect = attrString.boundingRect(with: textViewSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        return size
        
    }

}
