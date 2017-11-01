import UIKit
import PopupDialog
import AFNetworking
import NVActivityIndicatorView
import SDWebImage



class SideMenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate  {
    @IBOutlet var tableViewSideMenu: UITableView!
    var arrayList = NSMutableArray()
    var arrayImages = NSMutableArray()
    var activity:NVActivityIndicatorView!
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

    override func viewDidLoad() {
        super.viewDidLoad()
         initializeTableviewUI()

    }
    
    func initializeTableviewUI(){
        initializeData()
        self.tableViewSideMenu.register(UINib(nibName: "SidemenuHeaderTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "SidemenuHeaderTableViewCell")
        self.tableViewSideMenu.register(UINib(nibName: "SidemenuContentTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "SidemenuContentTableViewCell")
        tableViewSideMenu.reloadData()
    }
    func initializeData(){
        arrayImages = [imageFiles().imageCalender!,imageFiles().imageCalender!,imageFiles().imageCalender!,imageFiles().imageAddShop!,imageFiles().imageLogout!]
        arrayList = ["Today's Assignment","Past Assignment","Shop Assigned","Add Shop","Logout"]

    }

    
    //MARK: - Tableview Delegate Methods -
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arrayList.count + 1
    }
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor.clear
        return viewHeader
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor.clear
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0{
            return self.view.frame.height/3.1
        }else{
            return self.view.frame.height/11
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath as NSIndexPath).section == 0 {
            let Cell = tableView.dequeueReusableCell(withIdentifier: "SidemenuHeaderTableViewCell") as! SidemenuHeaderTableViewCell!
            Cell!.imageViewUserImage.sd_setImage(with: URL(string: "https://lh3.googleusercontent.com/-GDlSc4gOqXA/WfbCf-PA1vI/AAAAAAAABQk/NzPh3xcoCJcY9GoKCe2ell0-a7erBD4XwCL0BGAYYCw/h1280/7429304438610927207%253Faccount_id%253D2"), placeholderImage: UIImage(named: "logo"))
            

            return Cell!
        }else{
            let Cell = tableView.dequeueReusableCell(withIdentifier: "SidemenuContentTableViewCell") as! SidemenuContentTableViewCell!
            Cell?.labelContentName.text = arrayList.object(at: indexPath.section-1) as? String
            Cell?.imageViewContentImage.image = arrayImages.object(at: indexPath.section-1) as? UIImage
            return Cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableViewSideMenu.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1{
            let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }else if indexPath.section == 2{
            let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"PastAssignmentViewController") as! PastAssignmentViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }else if indexPath.section == 3{
            let nextViewController = self.storyBoard.instantiateViewController(withIdentifier:"ShopsAssignedViewController") as! ShopsAssignedViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }else if indexPath.section == 4{
            
        }else if indexPath.section == 5{
            
        }
    }

    

}
