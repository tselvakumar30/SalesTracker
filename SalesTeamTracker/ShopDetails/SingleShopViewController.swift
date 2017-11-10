import UIKit
import XLPagerTabStrip
import PopupDialog
import AFNetworking
import NVActivityIndicatorView


class SingleShopViewController: SegmentedPagerTabStripViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate {
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    var panGesture = UIPanGestureRecognizer()
    var fYofSegment = CGFloat()
    var fYofDetails = CGFloat()
    var fCenterOfView = CGFloat()
    var fLastPoint = CGFloat()
    @IBOutlet var collectionViewImages: UICollectionView!
    @IBOutlet var labelShopName: UILabel!
    @IBOutlet var labelAddress: UILabel!
    var arrayCollectionView = NSArray()
    @IBOutlet var pageControl: UIPageControl!
    var nIndexpath = Int()
    var dictionaryShopDetails = NSDictionary()
    @IBOutlet var viewMiddleView: UIView!
    @IBOutlet var viewHeader: UIView!
    var imageAddForShop = UIImage()
    let imagePicker = UIImagePickerController()
    
    var activity:NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        setLoadingIndicator()
        fCenterOfView = (self.view.frame.height - 20) / 2
        fYofSegment = viewMiddleView.frame.origin.y+viewMiddleView.frame.height
        fYofDetails = containerView.center.y
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        segmentedControl.isUserInteractionEnabled = true
        segmentedControl.addGestureRecognizer(panGesture)
        
    }
    
    
    func initializeUI(){
        
        self.collectionViewImages.register(UINib(nibName: "ShopDetailsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ShopDetailsCollectionViewCell")
        
        if let arrayImageList:NSArray = dictionaryShopDetails.value(forKey: "images") as? NSArray{
            arrayCollectionView = arrayImageList
            if arrayCollectionView.count <= 1{
                pageControl.isHidden = true
            }
        }
        
        labelShopName.text = dictionaryShopDetails.value(forKey: "shopname") as? String
        labelAddress.text = dictionaryShopDetails.value(forKey: "shopaddress") as? String
        
        pageControl.numberOfPages = arrayCollectionView.count
        pageControl.frame = CGRect(x:0,y:self.collectionViewImages.frame.size.height,width: self.pageControl.frame.size.width, height: self.pageControl.frame.size.height)
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: CGFloat(self.collectionViewImages.frame.size.width), height: CGFloat(self.collectionViewImages.frame.size.height))
        collectionViewImages.collectionViewLayout = layout
        collectionViewImages.frame = CGRect(x:0,y:0,width: self.collectionViewImages.frame.size.width, height: self.collectionViewImages.frame.size.height)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState.selected)
        segmentedControl.frame = CGRect(x: segmentedControl.frame.origin.x, y: segmentedControl.frame.origin.y, width: segmentedControl.frame.size.width, height: 40)
        
        
        collectionViewImages.reloadData()
        
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubview(toFront: segmentedControl)
        let translation = sender.translation(in: self.view)
        if sender.state == .ended{
            if fLastPoint < fCenterOfView{
                segmentedControl.frame = CGRect(x: segmentedControl.frame.origin.x, y: viewHeader.frame.height, width: self.segmentedControl.frame.size.width, height: 40)
                
                let fCenterContainerY:CGFloat = containerView.frame.height / 2
                // containerView.center = CGPoint(x: containerView.center.x, y: fCenterContainerY + viewHeader.frame.height+39)
                containerView.frame = CGRect(x: containerView.frame.origin.x, y: segmentedControl.frame.origin.y+39, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                
                containerView.isUserInteractionEnabled = true
            }else{
                segmentedControl.frame = CGRect(x: segmentedControl.frame.origin.x, y: fYofSegment, width: self.segmentedControl.frame.size.width, height: 40)
                //   containerView.center = CGPoint(x: containerView.center.x, y: fYofDetails)
                containerView.frame = CGRect(x: containerView.frame.origin.x, y: segmentedControl.frame.origin.y+39, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
                
                containerView.isUserInteractionEnabled = false
                
            }
        }else {
            segmentedControl.center = CGPoint(x: segmentedControl.center.x, y: segmentedControl.center.y + translation.y)
            containerView.center = CGPoint(x: containerView.center.x, y: containerView.center.y + translation.y)
            fLastPoint = segmentedControl.center.y
            containerView.isUserInteractionEnabled = false
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ActivityViewController")
        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StockViewController")
        let child_3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageViewController")
        return [child_1,child_2,child_3]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonAddCart(_ sender:Any){
        
        let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"AddCartViewController") as! AddCartViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @IBAction func buttonAddImageForShop(_ sender:Any){
        SelectImage()
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
        if let sImageUrl:String = (arrayCollectionView[indexPath.row] as AnyObject).value(forKey: "main_image") as? String{
            var sImage:String = ""
            sImage = ApiString().baseUrl + sImageUrl
            let Url:URL = URL(string: sImage)!
            cell.imageViewImage.sd_setImage(with: Url, completed: nil)
        }
        
        return cell
    }
    //MARK : ScrollView
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionViewImages {
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
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func SelectImage()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicker.delegate = self
            self.camera()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageAddForShop = chosenImage
        dismiss(animated: true, completion: nil)
        
        let dictionaryFullDetails:NSDictionary = UserDefaults.standard.value(forKey: "CURRENTSHOPDETAILS") as! NSDictionary
        let parameter = NSMutableDictionary()
        parameter.setValue(UserDefaults.standard.value(forKey: "USERID"), forKey: "userid")
        if let sShopId:String = dictionaryFullDetails.value(forKey: "shopid") as? String{
            parameter.setValue(sShopId, forKey: "shopid")
        }
        AddImage(params: parameter)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: ActionSheet Delegate
    
    func showActionSheet()
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
    
    //MARK:- Webservices
    func AddImage(params:NSMutableDictionary)
    {
        startLoading()
        let manager = AFHTTPSessionManager()
        let stringURL:NSString = String(format: "%@%@", ApiString().baseUrl,ApiString().addShopImagesUrl) as NSString
        
        manager.requestSerializer.setValue(UserDefaults.standard.value(forKey: "AUTHENTICATION") as? String, forHTTPHeaderField: "Auth-Token")
        manager.post(stringURL as String, parameters: params, constructingBodyWith: {
            (data: AFMultipartFormData!) in
            let strData:Data = UIImageJPEGRepresentation(self.imageAddForShop, 0.3)!
            data.appendPart(withFileData: strData, name: "fileToUpload[]", fileName: "photo.jpg", mimeType: "image/jpeg")
            
        }, progress: nil, success: { (operation, responseObject) -> Void in
            let responseDictionary:NSDictionary = responseObject as! NSDictionary
            if let _:Any = (responseDictionary).value(forKey: "status")
            {
                let strStatus:NSString = (responseDictionary).value(forKey: "status") as! NSString
                if strStatus == "true"{
                    print(responseDictionary)
                    if let arrayImageList:NSArray = responseDictionary.value(forKey: "images") as? NSArray{
                        self.arrayCollectionView = arrayImageList
                        if self.arrayCollectionView.count <= 1{
                            self.pageControl.isHidden = true
                        }
                        self.pageControl.numberOfPages = self.arrayCollectionView.count
                        self.collectionViewImages.reloadData()
                    }
                    self.stopLoading()
                    if let Msg:String = (responseDictionary).value(forKey: "msg") as? String{
                        self.popupAlert(Title: "Information", msg: Msg)
                    }
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

