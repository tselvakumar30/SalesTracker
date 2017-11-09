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
        if (textFieldUserName.text?.characters.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter Username")
        }else if (textFieldPassword.text?.characters.count)! <= 5 {
            self.popupAlert(Title: "Information",msg: "Password must be atleast 6 Characters")
        }else{
            let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
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

