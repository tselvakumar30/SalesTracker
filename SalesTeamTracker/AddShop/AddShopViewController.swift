import UIKit
import DropDown
import GooglePlaces
import PopupDialog
import NVActivityIndicatorView
import AFNetworking
import CoreLocation

class AddShopViewController: UIViewController ,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,CLLocationManagerDelegate {
    var activity:NVActivityIndicatorView!
    var locationManager:CLLocationManager!
    var dUserCurrentLatitude:Double = 0.0
    var dUserCurrentLongitude:Double = 0.0
    var dShopCurrentLatitude:Double = 0.0
    var dShopCurrentLongitude:Double = 0.0
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
    var arrayCountry = NSArray()
    var arrayState = NSArray()
    var arrayArea = NSArray()
    
    var nCountryId:Int = 1
    var nStateId:Int = 1
    var nAreaId:Int = 1
    
    
    @IBOutlet var collectionViewAddShop: UICollectionView!
    
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoadingIndicator()
        setUIProperties()
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textFieldCountryName.inputAccessoryView = doneToolbar
        textFieldStreetName.inputAccessoryView = doneToolbar
        textFieldLocation.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction(){
        textFieldCountryName.resignFirstResponder()
        textFieldStreetName.resignFirstResponder()
        textFieldLocation.resignFirstResponder()
        if nTextFieldTags == 2{
            let parameter = NSMutableDictionary()
            parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
            parameter.setValue(self.nStateId, forKey: "stateid")
            self.GetArea(params: parameter)
        }else if nTextFieldTags == 1{
            let parameter = NSMutableDictionary()
            parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
            parameter.setValue(self.nCountryId, forKey: "countryid")
            self.GetState(params: parameter)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        GetCountry(params: parameter)
        determineMyCurrentLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // CoreLocation - Get Location
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        self.locationManager?.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        dUserCurrentLatitude = userLocation.coordinate.latitude
        dUserCurrentLongitude = userLocation.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
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
        }else if arrayCollectionView.count == 0{
            self.popupAlert(Title: "Information",msg: "Please Add Atleast One Shop Photo")
        }else if dShopCurrentLatitude == 0.0 || dShopCurrentLongitude == 0.0{
            self.popupAlert(Title: "Information",msg: "Please Enter Valid Shop Address")
        }else{
            let parameter = NSMutableDictionary()
            parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
            parameter.setValue(textFieldShopName.text, forKey: "shopname")
            parameter.setValue(textFieldShopAddress.text, forKey: "shopaddress")
            /*parameter.setValue(dUserCurrentLatitude, forKey: "latitude")
            parameter.setValue(dUserCurrentLongitude, forKey: "longitude")
            parameter.setValue(dShopCurrentLatitude, forKey: "latitude2")
            parameter.setValue(dShopCurrentLongitude, forKey: "longitude2")*/
            parameter.setValue(dShopCurrentLatitude, forKey: "latitude")
            parameter.setValue(dShopCurrentLongitude, forKey: "longitude")
            parameter.setValue(0, forKey: "latitude2")
            parameter.setValue(0, forKey: "longitude2")
            parameter.setValue(textFieldPersonName.text, forKey: "uniqueid")
            parameter.setValue(textFieldPhone.text, forKey: "phonenumber")
            parameter.setValue(textFieldLandmark.text, forKey: "landmark")
            parameter.setValue(nCountryId, forKey: "country")
            parameter.setValue(nStateId, forKey: "state")
            parameter.setValue(nAreaId, forKey: "area")
            AddShop(params: parameter)
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
            arrayPickerview = arrayCountry
            nTextFieldTags = 1
            pickerviewList.showsSelectionIndicator = true
            textFieldCountryName.inputView = pickerviewList
            pickerviewList.reloadAllComponents()
        }
        if textField == textFieldStreetName{
            arrayPickerview = arrayState
            nTextFieldTags = 2
            pickerviewList.showsSelectionIndicator = true
            textFieldStreetName.inputView = pickerviewList
            pickerviewList.reloadAllComponents()
        }
        if textField == textFieldLocation{
            arrayPickerview = arrayArea
            nTextFieldTags = 3
            textFieldLocation.inputView = pickerviewList
            pickerviewList.reloadAllComponents()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textFieldShopAddress{
            self.getShopCoordinates(strTextField: textFieldShopAddress.text!)
        }
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
        if nTextFieldTags == 1{
            title = ((arrayPickerview[row] as AnyObject).value(forKey: "country") as? String)!
        }else if nTextFieldTags == 2{
            title = ((arrayPickerview[row] as AnyObject).value(forKey: "state") as? String)!
        }else if nTextFieldTags == 3{
            title = ((arrayPickerview[row] as AnyObject).value(forKey: "area") as? String)!
        }
        return title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if nTextFieldTags == 1{
            textFieldCountryName.text = (arrayPickerview[row] as AnyObject).value(forKey: "country") as? String
            nCountryId = Int(((self.arrayPickerview[row] as AnyObject).value(forKey: "countryid") as? String)!)!
        }else if nTextFieldTags == 2{
            textFieldStreetName.text = (arrayPickerview[row] as AnyObject).value(forKey: "state") as? String
            nStateId = Int(((self.arrayPickerview[row] as AnyObject).value(forKey: "stateid") as? String)!)!
        }else if nTextFieldTags == 3{
            textFieldLocation.text = (arrayPickerview[row] as AnyObject).value(forKey: "area") as? String
            nAreaId = Int(((self.arrayPickerview[row] as AnyObject).value(forKey: "areaid") as? String)!)!
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
    
    //MARK:- Webservices
    func GetCountry(params:NSMutableDictionary)
    {
        textFieldStreetName.text = ""
        textFieldLocation.text = ""
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().countryUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "countryList") as? NSArray{
                        self.arrayCountry = arrayResults
                        self.textFieldCountryName.text = (self.arrayCountry[0] as AnyObject).value(forKey: "country") as? String
                        self.nCountryId = Int(((self.arrayCountry[0] as AnyObject).value(forKey: "countryid") as? String)!)!
                    }
                    let parameter = NSMutableDictionary()
                    parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
                    parameter.setValue(self.nCountryId, forKey: "countryid")
                    self.GetState(params: parameter)
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
    func GetState(params:NSMutableDictionary)
    {
        textFieldLocation.text = ""
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().stateUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "StateList") as? NSArray{
                        self.arrayState = arrayResults
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
    func GetArea(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().sreaUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "areaList") as? NSArray{
                        self.arrayArea = arrayResults
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
    
    func AddShop(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().addShopUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        
        manager.post(stringURL as String, parameters: params, constructingBodyWith: {
            (data: AFMultipartFormData!) in
            if self.arrayCollectionView.count > 0{
            for i in 0 ... self.arrayCollectionView.count - 1{
                let strData:Data = UIImageJPEGRepresentation((self.arrayCollectionView[i] as? UIImage)!, 0.3)!
                data.appendPart(withFileData: strData, name: "fileToUpload[]", fileName: "photo\(i).jpg", mimeType: "image/jpeg")
            }
            }
        }, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    if let Msg:String = (responseDictionary).value(forKey: "msg") as? String{
                        self.popupAlert(Title: "Information", msg: Msg)
                    }
                    self.stopLoading()
                    self.navigationController?.popViewController(animated: true)
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
    
    // MARK:- Get Latitude&Longitude of Shop Address
    
    func getShopCoordinates(strTextField:String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(strTextField) { (placemarks, error) in
            if error == nil{
                let placemarks = placemarks
                let location:CLLocation = (placemarks?.first?.location)!
                self.dShopCurrentLatitude = (location.coordinate.latitude)
                self.dShopCurrentLongitude = (location.coordinate.longitude)
            }
            else {
            }
        }
    
    }
        
    
}

