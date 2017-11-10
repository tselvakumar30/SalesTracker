import UIKit
import XLPagerTabStrip


class StockViewController: UIViewController,IndicatorInfoProvider,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet var collectionViewStocks: UICollectionView!
    var arrayCollectionView = NSMutableArray()
    var arrayCollectionViewImages = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTableviewUI()

    }
    
    func initializeTableviewUI(){
        let parameter = NSMutableDictionary()
        let parameter1 = NSMutableDictionary()
        let parameter2 = NSMutableDictionary()
        self.collectionViewStocks.register(UINib(nibName: "StockCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StockCollectionViewCell")
        let image1:UIImage = UIImage(named: "logo")!
        let image2:UIImage = UIImage(named: "logo")!
        let image3:UIImage = UIImage(named: "logo")!
        arrayCollectionViewImages = [image1,image2,image3]

        parameter.setValue("Petbuddy", forKey: "productName")
        parameter.setValue("3", forKey: "productCount")

        parameter1.setValue("DigiIQ", forKey: "productName")
        parameter1.setValue("2", forKey: "productCount")

        parameter2.setValue("Pluggdd", forKey: "productName")
        parameter2.setValue("5", forKey: "productCount")
        
        arrayCollectionView.add(parameter)
        arrayCollectionView.add(parameter1)
        arrayCollectionView.add(parameter2)
        print(arrayCollectionView)
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        layout.itemSize = CGSize(width: CGFloat(self.collectionViewStocks.frame.size.width/2.1), height: CGFloat(self.collectionViewStocks.frame.size.height/2.25))
        collectionViewStocks.collectionViewLayout = layout
        collectionViewStocks.frame = CGRect(x:5,y:0,width: self.collectionViewStocks.frame.size.width-10, height: self.collectionViewStocks.frame.size.height)
        collectionViewStocks.reloadData()
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
        cell.imageViewProductImage.sd_setImage(with: URL(string: "https://images-na.ssl-images-amazon.com/images/I/41ylyIRaRoL._SY300_.jpg"), placeholderImage: UIImage(named: "logo"))
        cell.labelProductName.text = (arrayCollectionView[indexPath.row] as AnyObject).value(forKey:"productName") as? String
        cell.labelCountValues.text = (arrayCollectionView[indexPath.row] as AnyObject).value(forKey:"productCount") as? String

        cell.labelCountValues.tag = indexPath.row
        cell.buttonIncrement.tag = indexPath.row
        cell.buttonDecrement.tag = indexPath.row
        cell.buttonIncrement.addTarget(self, action: #selector(self.buttonIncrement), for: .touchUpInside)
        cell.buttonDecrement.addTarget(self, action: #selector(self.buttonDecrement), for: .touchUpInside)

        return cell
    }

    @objc func buttonIncrement(sender:UIButton)
    {
        print(sender.tag)
        // Pass values to webservice
    }

    @objc func buttonDecrement(sender:UIButton)
    {
        print(sender.tag)
    }

    //MARK : ScrollView

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Stock")
    }

}
