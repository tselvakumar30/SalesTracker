import UIKit
import PopupDialog
import AFNetworking
import NVActivityIndicatorView

class AddCartViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource,UITextFieldDelegate {
    @IBOutlet var collectionViewAddCart: UICollectionView!
    var arrayCollectionView = NSMutableArray()
    var arrayCollectionViewImages = NSMutableArray()
    var duplicateArray = NSMutableArray()

    @IBOutlet var viewTextField: UIView!
    
    var activity:NVActivityIndicatorView!
    
    @IBOutlet var textFieldSearch: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableviewUI()
        setLoadingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        GetProducts(params: parameter)
    }
    
    func initializeTableviewUI(){
        self.collectionViewAddCart.register(UINib(nibName: "StockCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StockCollectionViewCell")
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        layout.itemSize = CGSize(width: CGFloat(self.collectionViewAddCart.frame.size.width/2.07), height: CGFloat(self.collectionViewAddCart.frame.size.height/2.1))
        collectionViewAddCart.collectionViewLayout = layout
        viewTextField.layer.cornerRadius = viewTextField.frame.height/2.5
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StockCollectionViewCell", for: indexPath as IndexPath) as! StockCollectionViewCell
        
        if let sName:String = (arrayCollectionView[indexPath.row] as AnyObject).value(forKey: "productname") as? String{
            cell.labelProductName.text = sName
        }
        
        if let sCount:Int = (arrayCollectionView[indexPath.row] as AnyObject).value(forKey: "stock") as? Int{
            cell.labelCountValues.text = String(sCount)
        }
        
        if let arrayImageUrl:NSArray = (arrayCollectionView[indexPath.row] as AnyObject).value(forKey: "images") as? NSArray{
            if arrayImageUrl.count > 0{
                if let sImageUrl:String = (arrayImageUrl[0] as AnyObject).value(forKey: "main_image") as? String{
                    var sImage:String = ""
                    sImage = ApiString().baseUrl + sImageUrl
                    let Url:URL = URL(string: sImage)!
                    cell.imageViewProductImage.sd_setImage(with: Url, completed: nil)
                }
            }
        }
        
        cell.buttonIncrement.tag = indexPath.row
        cell.buttonDecrement.tag = indexPath.row
        cell.buttonIncrement.addTarget(self, action: #selector(self.buttonIncrement), for: .touchUpInside)
        cell.buttonDecrement.addTarget(self, action: #selector(self.buttonDecrement), for: .touchUpInside)
        
        return cell
    }
    
    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }

    @objc func buttonIncrement(sender:UIButton)
    {
        var nValue:Int = 0
        if let nStock:Int = (arrayCollectionView[sender.tag] as AnyObject).value(forKey: "stock") as? Int{
            nValue = nStock
                nValue = nValue + 1
                let newdict:NSDictionary = arrayCollectionView[sender.tag] as! NSDictionary
                let dictMute = NSMutableDictionary()
                dictMute.addEntries(from: newdict as! [AnyHashable : Any])
                dictMute.setValue(nValue, forKey: "stock")
                arrayCollectionView.replaceObject(at: sender.tag, with: dictMute)
                if let sId:String = (arrayCollectionView[sender.tag] as AnyObject).value(forKey: "productid") as? String{
                    for i in 0 ... duplicateArray.count - 1{
                        if let sDupliId:String = (duplicateArray[i] as AnyObject).value(forKey: "productid") as? String{
                            if sId == sDupliId{
                                duplicateArray.replaceObject(at: i, with: dictMute)
                            }
                        }
                    }
                }
        }
        collectionViewAddCart.reloadData()
        
    }
    
    @objc func buttonDecrement(sender:UIButton)
    {
        var nValue:Int = 0
        if let nStock:Int = (arrayCollectionView[sender.tag] as AnyObject).value(forKey: "stock") as? Int{
            nValue = nStock
            if nStock == 0{
                popupAlert(Title: "Information", msg: "Please Increase the stock!. Its already 0")
                return
            }else{
                nValue = nValue - 1
                let newdict:NSDictionary = arrayCollectionView[sender.tag] as! NSDictionary
                let dictMute = NSMutableDictionary()
                dictMute.addEntries(from: newdict as! [AnyHashable : Any])
                dictMute.setValue(nValue, forKey: "stock")
                arrayCollectionView.replaceObject(at: sender.tag, with: dictMute)
                if let sId:String = (arrayCollectionView[sender.tag] as AnyObject).value(forKey: "productid") as? String{
                    for i in 0 ... duplicateArray.count - 1{
                        if let sDupliId:String = (duplicateArray[i] as AnyObject).value(forKey: "productid") as? String{
                            if sId == sDupliId{
                                duplicateArray.replaceObject(at: i, with: dictMute)
                            }
                        }
                    }
                }
            }
        }
        collectionViewAddCart.reloadData()
        
    }
    
    @IBAction func buttonSaveProduct(_ sender: Any)
    {
        let dictionaryFullDetails:NSDictionary = UserDefaults.standard.value(forKey: "CURRENTSHOPDETAILS") as! NSDictionary
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        if let sShopId:String = dictionaryFullDetails.value(forKey: "shopid") as? String{
            parameter.setValue(sShopId, forKey: "shopid")
        }
        var bIsStockAdded:Bool = false
        let arrayPassValues = NSMutableArray()
        for i in 0 ... arrayCollectionView.count - 1{
            if let nStock:Int = (arrayCollectionView[i] as AnyObject).value(forKey: "stock") as? Int{
                if nStock != 0{
                    bIsStockAdded = true
                    let param = NSMutableDictionary()
                    if let sId:String = (arrayCollectionView[i] as AnyObject).value(forKey: "productid") as? String{
                        param.setValue(sId, forKey: "productid")
                    }
                    if let nCount:Int = (arrayCollectionView[i] as AnyObject).value(forKey: "stock") as? Int{
                        param.setValue(nCount, forKey: "orderplaced")
                    }
                    arrayPassValues.add(param)
                }
            }
        }
        parameter.setValue(arrayPassValues, forKey: "data")
        
        if bIsStockAdded{
            do {
                let jsonData = try? JSONSerialization.data(withJSONObject: parameter, options: JSONSerialization.WritingOptions(rawValue: 0))
                let objectString = String(data: jsonData!, encoding: .utf8)
                let passParam = NSMutableDictionary()
                passParam.setValue(objectString, forKey: "order_value")
                AddCart(params: passParam)
                print(passParam)
            }
        }else{
            popupAlert(Title: "Information", msg: "Please add atleast one product!")
        }
    }
    
    @IBAction func buttonSearchProduct(_ sender: Any) {
        textFieldSearch.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchAutocompleteEntriesWithSubstring(substring: textField.text!)
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        arrayCollectionView.removeAllObjects()
        if substring == ""{
            arrayCollectionView.addObjects(from: duplicateArray as [AnyObject])
        }else{
            for i in 0 ..< duplicateArray.count {
                let myString:NSString = (duplicateArray[i] as AnyObject).value(forKey: "productname") as! NSString
                let substringRange:NSRange = myString.range(of: substring, options: .caseInsensitive)
                if (substringRange.location  != NSNotFound)
                {
                    arrayCollectionView.add(duplicateArray[i])
                }
            }
        }
        collectionViewAddCart.reloadData()
    }
    
    func setStockAsZero(){
        for i in 0 ... arrayCollectionView.count - 1{
            let newdict:NSDictionary = arrayCollectionView[i] as! NSDictionary
            let dictMute = NSMutableDictionary()
            dictMute.addEntries(from: newdict as! [AnyHashable : Any])
            dictMute.setValue(0, forKey: "stock")
            arrayCollectionView.replaceObject(at: i, with: dictMute)
            duplicateArray.replaceObject(at: i, with: dictMute)
        }
        collectionViewAddCart.reloadData()
    }
    
    //MARK:- Webservices
    func GetProducts(params:NSMutableDictionary)
    {
        arrayCollectionView.removeAllObjects()
        duplicateArray.removeAllObjects()
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().productUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "results") as? NSArray{
                        self.duplicateArray.addObjects(from: arrayResults as! [Any])
                        self.arrayCollectionView.addObjects(from: arrayResults as! [Any])
                    }
                    self.setStockAsZero()
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
    func AddCart(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().cartUrl) as NSString
        
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
