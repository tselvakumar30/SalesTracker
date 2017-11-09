import UIKit
import XLPagerTabStrip

class SingleShopViewController: SegmentedPagerTabStripViewController,UICollectionViewDelegate,UICollectionViewDataSource {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
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
    
}
