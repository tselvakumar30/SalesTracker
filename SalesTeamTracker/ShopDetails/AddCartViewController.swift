import UIKit

class AddCartViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource,UITextFieldDelegate {
    @IBOutlet var collectionViewAddCart: UICollectionView!
    var arrayCollectionView = NSMutableArray()
    var arrayCollectionViewImages = NSMutableArray()
    var duplicateArray = NSMutableArray()

    @IBOutlet var viewTextField: UIView!
    
    @IBOutlet var textFieldSearch: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableviewUI()
        
    }
    
    func initializeTableviewUI(){
        let parameter = NSMutableDictionary()
        let parameter1 = NSMutableDictionary()
        let parameter2 = NSMutableDictionary()
        self.collectionViewAddCart.register(UINib(nibName: "StockCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "StockCollectionViewCell")
        
        parameter.setValue("Petbuddy", forKey: "productName")
        parameter.setValue("0", forKey: "productCount")
        
        parameter1.setValue("DigiIQ", forKey: "productName")
        parameter1.setValue("0", forKey: "productCount")
        
        parameter2.setValue("Pluggdd", forKey: "productName")
        parameter2.setValue("0", forKey: "productCount")
        
        arrayCollectionView.add(parameter)
        arrayCollectionView.add(parameter1)
        arrayCollectionView.add(parameter2)
        duplicateArray.add(parameter)
        duplicateArray.add(parameter1)
        duplicateArray.add(parameter2)
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        layout.itemSize = CGSize(width: CGFloat(self.collectionViewAddCart.frame.size.width/2.07), height: CGFloat(self.collectionViewAddCart.frame.size.height/2.1))
        collectionViewAddCart.collectionViewLayout = layout
        viewTextField.layer.cornerRadius = viewTextField.frame.height/2.5
        collectionViewAddCart.reloadData()
        
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
    
    @IBAction func buttonBack(_ sender: Any)
    {
        _ = navigationController?.popViewController(animated: true)
    }

    @objc func buttonIncrement(sender:UIButton)
    {
        var dict = NSDictionary()
        dict = arrayCollectionView[sender.tag] as! NSDictionary
        let strCount:NSString = dict.value(forKey: "productCount") as! NSString
        if strCount.integerValue >= 0{
            let count:Int = strCount.integerValue + 1
            let strProductCount:String = String(format: "%d",count)
            dict.setValue(strProductCount, forKey: "productCount")
        }
        
        arrayCollectionView.replaceObject(at: sender.tag, with: dict)
        collectionViewAddCart.reloadData()
        
    }
    
    @objc func buttonDecrement(sender:UIButton)
    {
        var dict = NSDictionary()
        dict = arrayCollectionView[sender.tag] as! NSDictionary
        let strCount:NSString = dict.value(forKey: "productCount") as! NSString
        if strCount.integerValue != 0{
            let count:Int = strCount.integerValue - 1
            let strProductCount:String = String(format: "%d",count)
            dict.setValue(strProductCount, forKey: "productCount")
        }
        
        arrayCollectionView.replaceObject(at: sender.tag, with: dict)
        collectionViewAddCart.reloadData()
        
    }
    
    @IBAction func buttonSaveProduct(_ sender: Any)
    {
        
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
                let myString:NSString = (duplicateArray[i] as AnyObject).value(forKey: "productName") as! NSString
                let substringRange:NSRange = myString.range(of: substring, options: .caseInsensitive)
                if (substringRange.location  != NSNotFound)
                {
                    arrayCollectionView.add(duplicateArray[i])
                }
            }
        }
        collectionViewAddCart.reloadData()
    }
    
}
