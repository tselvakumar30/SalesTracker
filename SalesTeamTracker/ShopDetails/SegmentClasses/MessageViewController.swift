import UIKit
import XLPagerTabStrip


class MessageViewController: UIViewController,IndicatorInfoProvider,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet var tableViewComments: UITableView!
    @IBOutlet var viewTextField: UIView!
    @IBOutlet var textFieldMessage: UITextField!
    var arrayComments = NSMutableArray()
    
    @IBOutlet var buttonSend: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initializeUI()

    }
    
    func initializeUI(){
        viewTextField.layer.cornerRadius = textFieldMessage.frame.height/2.6
        self.tableViewComments.register(UINib(nibName: "CommentsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CommentsTableViewCell")
        
        let dict = NSMutableDictionary()
        let dict1 = NSMutableDictionary()
        let dict2 = NSMutableDictionary()
        dict.setValue("jksadkjas bndsndkj snkjasnD", forKey: "Message")
        dict1.setValue("JJK funcCKDLSKLSAD KLCJKLSADJ CDNNC  dsfjhsdjsdj cjkscjksckjsd ncknscnsdlkc sldclksdjclkjsdl sljcksldj numberOfSections(in tableView: UIIn", forKey: "Message")
        dict2.setValue("JJK funcCKDLSKLSAD KLCJKLSADJ CDNNC  dsfjhsdjsdj cjkscjksckjsd ncknscnsdlkc sldclksdjclkjsdl sljcksldj numberOfSections(in taklsdjlksdj fjlsj sdljklsdjlksad dasljdlasj djilajdlaj kaskljlaks saljlak aladkla anlakdnlsak bleView: UIIn", forKey: "Message")
        arrayComments.add(dict)
        arrayComments.add(dict1)
        arrayComments.add(dict2)
        
   //      self.tableViewComments.rowHeight = UITableViewAutomaticDimension
        tableViewComments.reloadData()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Comments")
    }
    
    //MARK: - Tableview Delegate Methods -
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arrayComments.count
    }
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
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
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        let strMessage:String = ((arrayComments.object(at: indexPath.section) as AnyObject).value(forKey: "Message") as? String)!
////        let rowHeight:CGSize = getHeightBasedonText(Message: strMessage, textViewSize: CGSize(width:self.view.frame.width/1.58,height: 999 ))
////        if rowHeight.height <= self.view.frame.height/12{
////            return self.view.frame.height/5.2
////        }else{
////            //return rowHeight.height + self.view.frame.height/7
////            return UITableViewAutomaticDimension
////        }
//        return UITableViewAutomaticDimension
//
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell") as! CommentsTableViewCell!
        let strMessage:String = ((arrayComments.object(at: indexPath.section) as AnyObject).value(forKey: "Message") as? String)!
   //     let textViewHeight:CGFloat = (Cell?.textViewMessage.frame.height)!
    //    let rowHeight:CGSize = getHeightBasedonText(Message: strMessage, textViewSize: CGSize(width:self.view.frame.width/1.58,height: 999 ))
//        if textViewHeight < rowHeight.height{
//         //   Cell?.textViewMessage.frame = CGRect(x: Cell?.textViewMessage.frame.origin.x, y: Cell?.textViewMessage.frame.origin.y, width: Cell?.textViewMessage.frame.width, height: Cell?.textViewMessage.frame.height)
//        }else{
//         //   Cell?.textViewMessage.frame.size = rowHeight
//        }
        Cell?.textViewMessage.text = strMessage
     //   Cell?.labelDate.frame = CGRect(x: (Cell?.labelDate.frame.origin.x)!, y:(Cell?.frame.height)!-25, width: (Cell?.labelDate.frame.width)!, height: 20)

        return Cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }

    func getHeightBasedonText(Message:String,textViewSize:CGSize)->CGSize{

        let cellFont: UIFont? = (UIFont(name: "Helvetica", size: 16.0))
        let attrString = NSAttributedString.init(string: Message, attributes: [NSAttributedStringKey.font:cellFont])
        let rect = attrString.boundingRect(with: textViewSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        return size
        
    }

    @IBAction func buttonSendMessage(_ sender: Any)
    {
        let dict = NSMutableDictionary()
        dict.setValue(textFieldMessage.text!, forKey: "Message")
        arrayComments.add(dict)
        tableViewComments.reloadData()
    }
}
