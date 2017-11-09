import UIKit
import PopupDialog
import AFNetworking
import NVActivityIndicatorView
import GooglePlaces



class ViewController: UIViewController {
    
    @IBOutlet var textFieldPassword: UITextField!
    @IBOutlet var textFieldUserName: UITextField!
    @IBOutlet var viewBackground: UIView!
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var activity:NVActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLoadingIndicator()
        self.viewBackground = CodeReuser().createGradientLayer(view: self.viewBackground, fromColor: AppColors().appSkyBlueColor, toColor: AppColors().appBlueColor)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonLogin(_ sender: Any)
    {
        if (textFieldUserName.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter Username")
        }else if (textFieldPassword.text?.count)! <= 5 {
            self.popupAlert(Title: "Information",msg: "Password must be atleast 6 Characters")
        }else if ((UserDefaults.standard.value(forKey: "DEVICETOKEN") == nil)) {
            self.popupAlert(Title: "Information",msg: "Please Allow Push Notification in Settings")
        }else{
            let parameter = NSMutableDictionary()
            parameter.setValue(textFieldUserName.text, forKey: "loginid")
            parameter.setValue(textFieldPassword.text, forKey: "password")
            parameter.setValue("IOS", forKey: "device_type")
            parameter.setValue(UserDefaults.standard.value(forKey: "DEVICETOKEN"), forKey: "device_token")
            Registration(params: parameter)
        }
    }
    
    //MARK:- Webservices
    func Registration(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().loginUrl) as NSString
        
        let strAuth:String = textFieldUserName.text! + "-" + textFieldPassword.text!
        let data = (strAuth).data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        manager.requestSerializer.setValue(base64, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    UserDefaults.standard.set(responseDictionary, forKey: "USERDETAILS")
                    if let AccessToken:String = (responseDictionary).value(forKey: "token") as? String{
                        UserDefaults.standard.set(AccessToken, forKey:"AUTHENTICATION" )
                    }
                    if let strUserID:String = (responseDictionary).value(forKey: "userid") as? String{
                        UserDefaults.standard.set(strUserID, forKey:"USERID" )
                    }
                    let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"HomeViewController") as! HomeViewController
                    self.navigationController?.pushViewController(nextViewController, animated: true)
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
    
    
}

