import UIKit
import XLPagerTabStrip
import PopupDialog
import AFNetworking
import NVActivityIndicatorView

class StockViewController: UIViewController,IndicatorInfoProvider,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet var collectionViewStocks: UICollectionView!
    var arrayCollectionView = NSMutableArray()
    var arrayCollectionViewImages = NSMutableArray()
    
    var activity:NVActivityIndicatorView!
    var dictionaryFullDetails = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let dictDetails:NSDictionary = UserDefaults.standard.value(forKey: "CURRENTSHOPDETAILS") as? NSDictionary{
            dictionaryFullDetails = dictDetails
        }
        initializeTableviewUI()
        setLoadingIndicator()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        callStockWebservice()
    }
    
    func callStockWebservice(){
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        if let sAssignId:String = dictionaryFullDetails.value(forKey: "shopid") as? String{
            parameter.setValue(sAssignId, forKey: "shopid")
        }
        GetStockDetails(params: parameter)
    }
    
    func initializeTableviewUI(){
        self.collectionViewStocks.register(UINib(nibName: "StockCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StockCollectionViewCell")
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        layout.itemSize = CGSize(width: CGFloat(self.collectionViewStocks.frame.size.width/2.1), height: CGFloat(self.collectionViewStocks.frame.size.height/2.25))
        collectionViewStocks.collectionViewLayout = layout
        collectionViewStocks.frame = CGRect(x:5,y:0,width: self.collectionViewStocks.frame.size.width-10, height: self.collectionViewStocks.frame.size.height)
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
        if let sCount:String = (arrayCollectionView[indexPath.row] as AnyObject).value(forKey: "stock") as? String{
            cell.labelCountValues.text = sCount
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

        cell.labelCountValues.tag = indexPath.row
        cell.buttonIncrement.tag = indexPath.row
        cell.buttonDecrement.tag = indexPath.row
        cell.buttonIncrement.addTarget(self, action: #selector(self.buttonIncrement), for: .touchUpInside)
        cell.buttonDecrement.addTarget(self, action: #selector(self.buttonDecrement), for: .touchUpInside)

        return cell
    }

    @objc func buttonIncrement(sender:UIButton)
    {
        let parameter = NSMutableDictionary()
        if let sCount:String = (arrayCollectionView[sender.tag] as AnyObject).value(forKey: "stock") as? String{
            var nNewCount:Int = Int(sCount)!
            nNewCount = nNewCount + 1
            parameter.setValue(String(nNewCount), forKey: "stockvalue")
        }
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        if let sStockId:String = (arrayCollectionView[sender.tag] as AnyObject).value(forKey: "stockid") as? String{
            parameter.setValue(sStockId, forKey: "stockid")
        }
        UpdateStockDetails(params: parameter)
    }

    @objc func buttonDecrement(sender:UIButton)
    {
        let parameter = NSMutableDictionary()
        if let sCount:String = (arrayCollectionView[sender.tag] as AnyObject).value(forKey: "stock") as? String{
            var nNewCount:Int = Int(sCount)!
            if nNewCount != 0{
               nNewCount = nNewCount - 1
            }else{
                popupAlert(Title: "Information", msg: "Stock is already zero!")
                return
            }
            parameter.setValue(String(nNewCount), forKey: "stockvalue")
        }
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        if let sStockId:String = (arrayCollectionView[sender.tag] as AnyObject).value(forKey: "stockid") as? String{
            parameter.setValue(sStockId, forKey: "stockid")
        }
        UpdateStockDetails(params: parameter)
    }

    //MARK : ScrollView
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Stock")
    }
    
    //MARK:- Webservices
    func GetStockDetails(params:NSMutableDictionary)
    {
        arrayCollectionView.removeAllObjects()
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().stockUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    if let arrayResults:NSArray = responseDictionary.value(forKey: "results") as? NSArray{
                        self.arrayCollectionView.addObjects(from: arrayResults as! [Any])
                        self.collectionViewStocks.reloadData()
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
    func UpdateStockDetails(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().stockUpdateUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    self.callStockWebservice()
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
