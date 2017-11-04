import UIKit

class ShopDetailsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    
    @IBOutlet var collectionViewImages: UICollectionView!
    @IBOutlet var labelShopName: UIView!
    @IBOutlet var labelAddress: UILabel!
    var arrayCollectionView = NSArray()
    @IBOutlet var pageControl: UIPageControl!
    var nIndexpath = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeUI()
    }
    
    func initializeUI(){
        
        self.collectionViewImages.register(UINib(nibName: "ShopDetailsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ShopDetailsCollectionViewCell")
        
        let image1:UIImage = UIImage(named: "logo")!
        let image2:UIImage = UIImage(named: "logo")!
        let image3:UIImage = UIImage(named: "logo")!
        arrayCollectionView = [image1,image2,image3]
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
        collectionViewImages.reloadData()

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
