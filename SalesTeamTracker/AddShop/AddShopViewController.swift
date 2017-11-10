import UIKit
import DropDown
import GooglePlaces
import PopupDialog
import NVActivityIndicatorView



class AddShopViewController: UIViewController ,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource {
    var activity:NVActivityIndicatorView!
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
    var arrayPickerview = NSArray()
    var pickerviewList = UIPickerView()
    var nTextFieldTags = Int()
    var arrayCollectionView = NSMutableArray()
    @IBOutlet var pageControl: UIPageControl!
    var nIndexpath = Int()


    @IBOutlet var collectionViewAddShop: UICollectionView!
    
    let dropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        setLoadingIndicator()
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
        
        self.collectionViewAddShop.register(UINib(nibName: "ShopDetailsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ShopDetailsCollectionViewCell")
        pageControl.isHidden = true
        pageControl.numberOfPages = arrayCollectionView.count
        pageControl.frame = CGRect(x:0,y:self.collectionViewAddShop.frame.size.height-self.pageControl.frame.size.height,width: self.pageControl.frame.size.width, height: self.pageControl.frame.size.height)
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: CGFloat(self.collectionViewAddShop.frame.size.width), height: CGFloat(self.collectionViewAddShop.frame.size.height))
        collectionViewAddShop.collectionViewLayout = layout
    }

    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonSelectPhoto(_ sender: Any)
    {
        if (textFieldShopAddress.text?.count)! >= 1{
            self.SelectImage()
        }else{
            self.popupAlert(Title: "Information",msg: "Please Enter Address To select Image")
        }
    }
    
    @IBAction func buttonSave(_ sender: Any)
    {
        if imageViewShopImage.image == nil{
            self.popupAlert(Title: "Information",msg: "Please capture the shop image")
        }else if (textFieldShopName.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter Shop Name")
        }else if (textFieldShopAddress.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter Shop Address")
        }else if (textFieldLandmark.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter the Landmark")
        }else if (textFieldPhone.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter Shop Number")
        }else if (textFieldPersonName.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter Shopkeeper Name")
        }else if (textFieldCountryName.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter Country Name")
        }else if (textFieldStreetName.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter Street Name")
        }else if (textFieldLocation.text?.count)! <= 1{
            self.popupAlert(Title: "Information",msg: "Please Enter the Location")
        }else{
            
        }
    }

    //MARK: TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textFieldShopAddress{
            if(textFieldShopAddress.text?.count)! > 2 {
                placeAutocomplete()
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        pickerviewList.dataSource = self
        pickerviewList.delegate = self
        pickerviewList.showsSelectionIndicator = true
        if textField == textFieldCountryName{
            arrayPickerview = ["India","Pakis","Bangla","Canad"]
            nTextFieldTags = 1
            pickerviewList.showsSelectionIndicator = true
            textFieldCountryName.inputView = pickerviewList
            pickerviewList.reloadAllComponents()
        }
        if textField == textFieldStreetName{
            arrayPickerview = ["chn","mao","lef","Nagar","Road"]
            nTextFieldTags = 2
            pickerviewList.showsSelectionIndicator = true
            textFieldStreetName.inputView = pickerviewList
            pickerviewList.reloadAllComponents()
        }
        if textField == textFieldLocation{
            arrayPickerview = ["chn","mao","lef"]
            nTextFieldTags = 3
            textFieldLocation.inputView = pickerviewList
            pickerviewList.reloadAllComponents()
        }
        return true
    }
    
    //MARK:- Picker View Delegate and Datasource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayPickerview.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        
        var title = String()
        title = (arrayPickerview[row] as AnyObject)as! String
        return title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        var strSelected = String()
        strSelected = (arrayPickerview[row] as AnyObject)as! String
        if nTextFieldTags == 1{
            textFieldCountryName.text = strSelected
        }else if nTextFieldTags == 2{
            textFieldStreetName.text = strSelected
        }else if nTextFieldTags == 3{
            textFieldLocation.text = strSelected
        }
    }

    //MARK: ActionSheet Delegate
    
    func showActionSheet2()
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    func camera()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
    }

    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func SelectImage()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicker.delegate = self;
            self.camera()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        arrayCollectionView.add(chosenImage)
        pageControl.isHidden = false
        pageControl.numberOfPages = arrayCollectionView.count
        collectionViewAddShop.reloadData()
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
                    //
                    self.dropDown.show()
                }
            }
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
    

    
    //MARK: CollectionView Delegates and Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrayCollectionView.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopDetailsCollectionViewCell", for: indexPath as IndexPath) as! ShopDetailsCollectionViewCell
        cell.imageViewImage.image = arrayCollectionView[indexPath.row] as? UIImage

        return cell
    }
    
    //MARK : ScrollView
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionViewAddShop {
            if scrollView.contentOffset.x == 0 {
                pageControl.currentPage = 0
            }
            else if scrollView.contentOffset.x == (4 * view.bounds.size.width) {
                
            }
            else {
                let nPage: Int = (Int(scrollView.contentOffset.x / view.bounds.size.width))
                pageControl.currentPage = nPage
            }
        }
    }
    
    

    
    
}
