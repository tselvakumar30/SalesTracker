import UIKit

class AddShopViewController: UIViewController {

    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    @IBOutlet var buttonSave: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewScroll: UIView!
    @IBOutlet var imageViewShopImage: UIImageView!
    @IBOutlet var textFieldShopName: UITextField!
    @IBOutlet var textFieldLandmark: UITextField!
    @IBOutlet var textFieldShopAddress: UITextField!
    @IBOutlet var textFieldLocation: UITextField!
    @IBOutlet var textFieldStreetName: UITextField!
    @IBOutlet var textFieldCountryName: UITextField!
    @IBOutlet var textFieldPersonName: UITextField!
    @IBOutlet var textFieldPhone: UITextField!
    @IBOutlet var buttonAddImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUIProperties()
    }

    func setUIProperties(){
        scrollView.contentSize = CGSize(width: self.viewScroll.frame.width, height: self.buttonSave.frame.height+self.buttonSave.frame.origin.y+25)
        CodeReuser().setBorderToTextField(theTextField: textFieldLandmark, theView:self.view)
        CodeReuser().setBorderToTextField(theTextField: textFieldShopAddress, theView:self.view)
        CodeReuser().setBorderToTextField(theTextField: textFieldLocation, theView:self.view)
        CodeReuser().setBorderToTextField(theTextField: textFieldStreetName, theView:self.view)
        CodeReuser().setBorderToTextField(theTextField: textFieldCountryName, theView:self.view)
        CodeReuser().setBorderToTextField(theTextField: textFieldPersonName, theView:self.view)
        CodeReuser().setBorderToTextField(theTextField: textFieldPhone, theView:self.view)
        CodeReuser().setBorderToTextField(theTextField: textFieldShopName, theView:self.view)

    }

    
    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    


}
