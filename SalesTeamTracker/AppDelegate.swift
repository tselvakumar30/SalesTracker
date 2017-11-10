import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import DropDown
import UserNotifications




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
   
        IQKeyboardManager.sharedManager().enable = true
       GMSServices.provideAPIKey("AIzaSyB1XA8CUkcDrSXV6vGiScUrk8UZ9XVcFFU")
        GMSPlacesClient.provideAPIKey("AIzaSyB1XA8CUkcDrSXV6vGiScUrk8UZ9XVcFFU")
        DropDown.startListeningToKeyboard()
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            UserDefaults.standard.set("90cc0d0b47e357836cff5304dcf9a5d190a7080d61b6e4cd9691b55365fb846c", forKey: "DEVICETOKEN")
        #endif
        
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
            
        }
        application.registerForRemoteNotifications()
        
        navigation()

        return true
    }
    
    
    func navigation(){
        if let _:Any = UserDefaults.standard.value(forKey: "USERID"){
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let mainController = storyBoard.instantiateViewController(withIdentifier:"HomeViewController") as! HomeViewController
            let navigationController = UINavigationController(rootViewController: mainController)
            navigationController.navigationBar.isHidden = true
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        UserDefaults.standard.set(tokenString, forKey: "DEVICETOKEN")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
}
    /*
    let correctedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
    let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false")
    
    let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
        // 3
        do {
            if data != nil{
                let dic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as!  NSDictionary
                
                let lat = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lat")?.objectAtIndex(0) as! Double
                let lon = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lng")?.objectAtIndex(0) as! Double
                // 4
                self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row] )
            }
        }catch {
            print("Error")
        }


}*/

