import UIKit
import XLPagerTabStrip
import PopupDialog
import AFNetworking
import NVActivityIndicatorView

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
    
    var sPromotion:String = "0"
    var sSamples:String = "0"
    var sDemo:String = "0"
    var nStatusType:Int = 0
    
    var activity:NVActivityIndicatorView!
    var dictionaryFullDetails = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dictDetails:NSDictionary = UserDefaults.standard.value(forKey: "CURRENTSHOPDETAILS") as? NSDictionary{
            dictionaryFullDetails = dictDetails
            if let sDemoStatus:Int = dictDetails.value(forKey: "demo_status") as? Int{
                sDemo = String(sDemoStatus)
                if sDemoStatus == 0{
                    switchOrders.isOn = false
                }else{
                    switchOrders.isOn = true
                }
            }
            if let sPromotionStatus:Int = dictDetails.value(forKey: "promotion_status") as? Int{
                sPromotion = String(sPromotionStatus)
                if sPromotionStatus == 0{
                    switchPromotions.isOn = false
                }else{
                    switchPromotions.isOn = true
                }
            }
            if let sSampleStatus:Int = dictDetails.value(forKey: "sample_status") as? Int{
                sSamples = String(sSampleStatus)
                if sSampleStatus == 0{
                    switchStocks.isOn = false
                }else{
                    switchStocks.isOn = true
                }
            }
        }
        switchOrders.addTarget(self, action: #selector(self.clickOrder(sender:)), for: .valueChanged)
        switchStocks.addTarget(self, action: #selector(self.clickStocks(sender:)), for: .valueChanged)
        switchPromotions.addTarget(self, action: #selector(self.clickPromotion(sender:)), for: .valueChanged)
        setLoadingIndicator()
    }
    
    @objc func clickOrder(sender:UISwitch){
        nStatusType = 3
        if sDemo == "0"{
            sDemo = "1"
            callWebservice()
        }else{
            sDemo = "0"
            callWebservice()
        }
        
    }
    @objc func clickStocks(sender:UISwitch){
        nStatusType = 2
        if sSamples == "0"{
            sSamples = "1"
            callWebservice()
        }else{
            sSamples = "0"
            callWebservice()
        }
    }
    @objc func clickPromotion(sender:UISwitch){
        nStatusType = 1
        if sPromotion == "0"{
            sPromotion = "1"
            callWebservice()
        }else{
            sPromotion = "0"
            callWebservice()
        }
    }
    
    func callWebservice(){
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        if let sAssignId:String = dictionaryFullDetails.value(forKey: "assignmentid") as? String{
            parameter.setValue(sAssignId, forKey: "assignmentid")
        }
        if let sShopId:String = dictionaryFullDetails.value(forKey: "shopid") as? String{
            parameter.setValue(sShopId, forKey: "shopid")
        }
        parameter.setValue(sSamples, forKey: "sample_status")
        parameter.setValue(sPromotion, forKey: "promotion_status")
        parameter.setValue(sDemo, forKey: "demo_status")
        UpdateStatus(params: parameter)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Activity")
    }
    
    func setFailureUpdate(){
        if nStatusType == 1{
            if sPromotion == "0"{
                sPromotion = "1"
                switchPromotions.isOn = true
            }else{
                sPromotion = "0"
                switchPromotions.isOn = false
            }
        }else if nStatusType == 2{
            if sSamples == "0"{
                sSamples = "1"
                switchStocks.isOn = true
            }else{
                sSamples = "0"
                switchStocks.isOn = false
            }
        }else{
            if sDemo == "0"{
                sDemo = "1"
                switchOrders.isOn = true
            }else{
                sDemo = "0"
                switchOrders.isOn = false
            }
        }
    }
    
    //MARK:- Webservices
    func UpdateStatus(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().otherStatusUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    if let Msg:String = (responseDictionary).value(forKey: "msg") as? String{
                        self.popupAlert(Title: "Information", msg: Msg)
                    }
                    self.stopLoading()
                }else{
                    self.setFailureUpdate()
                    self.stopLoading()
                    if let Msg:String = (responseDictionary).value(forKey: "msg") as? String{
                        self.popupAlert(Title: "Information", msg: Msg)
                    }
                }
            }else{
                self.setFailureUpdate()
            }
        }, failure: { (operation, error) -> Void in
            self.setFailureUpdate()
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

