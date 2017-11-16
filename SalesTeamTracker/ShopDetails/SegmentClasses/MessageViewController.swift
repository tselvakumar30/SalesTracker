import UIKit
import XLPagerTabStrip
import PopupDialog
import AFNetworking
import NVActivityIndicatorView

class MessageViewController: UIViewController,IndicatorInfoProvider,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    @IBOutlet var tableViewComments: UITableView!
    @IBOutlet var viewTextField: UIView!
    @IBOutlet var textFieldMessage: UITextField!
    var arrayComments = NSMutableArray()
    var fKeyboardHeighaxis = CGFloat()
    var fTextFieldInitialYaxis = CGFloat()

    var activity:NVActivityIndicatorView!
    var dictionaryFullDetails = NSDictionary()
    var bSalesManDistance = Bool()

    @IBOutlet var buttonSend: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        bSalesManDistance = UserDefaults.standard.bool(forKey: "SalesManDistance")
        getKeyboardHeight()
        initializeUI()
        setLoadingIndicator()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCommentWebservice()
    }
    override func viewDidAppear(_ animated: Bool) {
        fTextFieldInitialYaxis = self.viewTextField.frame.origin.y
    }
    
    func getCommentWebservice(){
        if let dictDetails:NSDictionary = UserDefaults.standard.value(forKey: "CURRENTSHOPDETAILS") as? NSDictionary{
            dictionaryFullDetails = dictDetails
        }
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        if let sAssignId:String = dictionaryFullDetails.value(forKey: "assignmentid") as? String{
            parameter.setValue(sAssignId, forKey: "assignmentid")
        }
        if let sShopId:String = dictionaryFullDetails.value(forKey: "shopid") as? String{
            parameter.setValue(sShopId, forKey: "shopid")
        }
        GetComments(params: parameter)
    }
    
    func initializeUI(){
        viewTextField.layer.cornerRadius = textFieldMessage.frame.height/2.6
        self.tableViewComments.register(UINib(nibName: "CommentsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CommentsTableViewCell")
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell") as! CommentsTableViewCell!
        if let strMessage:String = (arrayComments.object(at: indexPath.section) as AnyObject).value(forKey: "comment") as? String{
            Cell?.textViewMessage.text = strMessage
        }
        if let arr:NSArray = (arrayComments.object(at: indexPath.section) as AnyObject).value(forKey: "comment_user_details") as? NSArray{
            if let sName:String = (arr.object(at: 0) as AnyObject).value(forKey: "firstname") as? String{
                Cell?.labelName.text = sName
            }
            if let sUrl:String = (arr.object(at: 0) as AnyObject).value(forKey: "thumbimage") as? String{
                var sImage:String = ""
                sImage = ApiString().baseUrl + sUrl
                let Url:URL = URL(string: sImage)!
                Cell?.imageViewUserImage.sd_setImage(with: Url, completed: nil)
            }
        }
        return Cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0
    }
    
    
    @IBAction func buttonSendMessage(_ sender: Any)
    {
        if bSalesManDistance == true{
            self.popupAlert(Title: "Information", msg: "You are far away from shop location")
        }else{
            if (textFieldMessage.text?.count)! > 0{
                let parameter = NSMutableDictionary()
                parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
                if let sAssignId:String = dictionaryFullDetails.value(forKey: "assignmentid") as? String{
                    parameter.setValue(sAssignId, forKey: "assignmentid")
                }
                if let sShopId:String = dictionaryFullDetails.value(forKey: "shopid") as? String{
                    parameter.setValue(sShopId, forKey: "shopid")
                }
                parameter.setValue(textFieldMessage.text, forKey: "comment")
                AddComments(params: parameter)
                textFieldMessage.text = ""
            }else{
                popupAlert(Title: "Information", msg: "Please add a comment!")
            }
        }
        
        self.viewTextField.frame.origin.y = fTextFieldInitialYaxis

    }
    
    //MARK:- Webservices
    func GetComments(params:NSMutableDictionary)
    {
        startLoading()
        arrayComments.removeAllObjects()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().singleAssignmentUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "comment_result") as? NSArray{
                        self.arrayComments.addObjects(from: arrayResults as! [Any])
                        self.tableViewComments.reloadData()
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
    func AddComments(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().commentUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    self.textFieldMessage.text = ""
                    self.getCommentWebservice()
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
    
    func getKeyboardHeight(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )

    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
             fKeyboardHeighaxis = keyboardRectangle.height
             self.viewTextField.frame.origin.y = fTextFieldInitialYaxis - keyboardRectangle.height
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        self.viewTextField.frame.origin.y = fTextFieldInitialYaxis
    }
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
   //     self.viewTextField.frame.origin.y = fTextFieldInitialYaxis - fKeyboardHeighaxis

        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
   //     self.viewTextField.frame.origin.y = fKeyboardHeighaxis + fTextFieldInitialYaxis
        return true
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
