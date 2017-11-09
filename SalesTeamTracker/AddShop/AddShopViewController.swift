import UIKit
import DropDown
import GooglePlaces



class AddShopViewController: UIViewController ,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    let imagePicker = UIImagePickerController()
    var imageUpload = UIImage()
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
    @IBOutlet weak var autocompleteContainerView: UIView!
    
    let dropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUIProperties()
    }

    func setUIProperties(){
        scrollView.contentSize = CGSize(width: self.viewScroll.frame.width, height: self.buttonSave.frame.height+self.buttonSave.frame.origin.y+25)
        CodeReuser().setBorderToTextFieldWithImage(theTextField: textFieldLandmark, theView:self.view, image: imageFiles().imageLandmark!)
        CodeReuser().setBorderToTextFieldWithImage(theTextField: textFieldShopAddress, theView:self.view, image: imageFiles().imageShopAddress!)
        CodeReuser().setBorderToTextFieldWithImage(theTextField: textFieldLocation, theView:self.view, image: imageFiles().imageLocate!)
        CodeReuser().setBorderToTextFieldWithImage(theTextField: textFieldStreetName, theView:self.view, image: imageFiles().imageLocate!)
        CodeReuser().setBorderToTextFieldWithImage(theTextField: textFieldCountryName, theView:self.view, image: imageFiles().imageLocate!)
        CodeReuser().setBorderToTextFieldWithImage(theTextField: textFieldPersonName, theView:self.view, image: imageFiles().imageUser!)
        CodeReuser().setBorderToTextFieldWithImage(theTextField: textFieldPhone, theView:self.view, image: imageFiles().imageAddPhone!)
        CodeReuser().setBorderToTextFieldWithImage(theTextField: textFieldShopName, theView:self.view, image: imageFiles().imageShopName!)
        dropDown.anchorView = self.textFieldShopAddress
        dropDown.dataSource = ["Car", "Motorcycle", "Truck"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
        }
        dropDown.dismissMode = .onTap
        dropDown.direction = .any
        dropDown.bottomOffset = CGPoint(x: 0, y: self.textFieldShopAddress.bounds.height)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.textFieldShopAddress.text = item
        }




    }

    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonSelectPhoto(_ sender: Any)
    {
        self.SelectImage()
    }
    
    //MARK: TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == textFieldShopAddress{
            
            if(textFieldShopAddress.text?.characters.count)! > 2 {
                placeAutocomplete()
            }
            
        }
        
        return true
    }


    //MARK: ActionSheet Delegate
    
    func showActionSheet2()
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Gallery", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    func camera()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func photoLibrary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func SelectImage()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicker.delegate = self;
            self.showActionSheet2()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            imageViewShopImage.image = chosenImage
            dismiss(animated: true, completion: nil)
    }

    
    func placeAutocomplete() {
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        filter.country = "IN"
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(textFieldShopAddress.text!, bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            let arrayAddress = NSMutableArray()
            if let results = results {
                for result in results {
                    print(result.attributedFullText.string)
                    arrayAddress.add(result.attributedFullText.string)
                }
                if arrayAddress.count > 0{
                    self.dropDown.dataSource = arrayAddress as! [String]
                    self.dropDown.show()
                }
            }
        })
    }
    
}
