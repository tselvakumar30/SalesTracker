import UIKit
import Foundation

class CodeReuser: NSObject
{
    func setBorderToTextField(theTextField: UITextField, theView:UIView){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor(red: 92.0/255.0, green: 94.0/255.0, blue: 102.0/255.0, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: theTextField.frame.size.height - width, width:  theView.frame.size.width, height: theTextField.frame.size.height)
        
        border.borderWidth = width
        theTextField.layer.addSublayer(border)
        theTextField.layer.masksToBounds = true
    }
    
    func setBorderToTextFieldWithImage(theTextField: UITextField, theView:UIView,image:UIImage){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor(red: 92.0/255.0, green: 94.0/255.0, blue: 102.0/255.0, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: theTextField.frame.size.height - width, width:  theView.frame.size.width , height: theTextField.frame.size.height)
        
        border.borderWidth = width
        let imageView = UIImageView(frame: CGRect(x: 2, y: 5, width: 25, height: 25))
        imageView.image = image
        theTextField.addSubview(imageView)
        theTextField.leftViewMode = .always
        theTextField.leftView = imageView

        theTextField.layer.addSublayer(border)
        theTextField.layer.masksToBounds = true
    }
    
    func createGradientLayer(view:UIView,fromColor:UIColor,toColor:UIColor)-> UIView {
        var gradientLayer: CAGradientLayer!
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = view.frame
        gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
        view.layer.addSublayer(gradientLayer)
        return view
    }
    func validateMail(textEmail: String) -> Bool
    {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: textEmail)
    }
    
    func viewCircular(circleView : UIView)
    {
        
        circleView.frame = CGRect(x: circleView.frame.origin.x, y: circleView.frame.origin.y, width: circleView.frame.size.width, height: circleView.frame.size.width)
        circleView.layer.cornerRadius = circleView.layer.frame.size.width/2
        circleView.layer.masksToBounds = true
    }

}
extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}


@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }else {
                return nil
            }
        }
    }
    
    @IBInspectable var shadowColor:UIColor? {
        set {
            layer.shadowColor = newValue!.cgColor
        }get {
            if let color = layer.shadowColor {
                return UIColor(cgColor:color)
            }else {
                return nil
            }
        }
    }
    
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }get {
            return layer.cornerRadius
        }
    }
    @IBInspectable var shadowRadius:CGFloat {
        set {
            layer.shadowRadius = newValue
            clipsToBounds = newValue > 0
        }get {
            return layer.shadowRadius
        }
    }
    @IBInspectable var shadowOffset:CGSize{
        set{
            layer.shadowOffset = newValue
        }get{
            return layer.shadowOffset
        }
    }
}

@IBDesignable
class CardView: UIView {
    
    @IBInspectable var cornerRadius1: CGFloat = 2

    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor1: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius1
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius1)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor1?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
}

extension String {
    
    // Returns true if the string has at least one character in common with matchCharacters.
    func containsCharactersIn(_ matchCharacters: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: matchCharacters)
        return self.rangeOfCharacter(from: characterSet) != nil
    }
    
    // Returns true if the string contains only characters found in matchCharacters.
    func containsOnlyCharactersIn(_ matchCharacters: String) -> Bool {
        let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    
    // Returns true if the string has no characters in common with matchCharacters.
    func doesNotContainCharactersIn(_ matchCharacters: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: matchCharacters)
        return self.rangeOfCharacter(from: characterSet) == nil
    }
    
    // Returns true if the string represents a proper numeric value.
    // This method uses the device's current locale setting to determine
    // which decimal separator it will accept.
    func isNumeric() -> Bool
    {
        let scanner = Scanner(string: self)
        
        // A newly-created scanner has no locale by default.
        // We'll set our scanner's locale to the user's locale
        // so that it recognizes the decimal separator that
        // the user expects (for example, in North America,
        // "." is the decimal separator, while in many parts
        // of Europe, "," is used).
        scanner.locale = Locale.current
        
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
    
}
extension UIView {
    
    func setCardView(shadowView : UIView){

        let cornerRad: CGFloat = 2
        
        let shadowOffsetWid: Int = 0
        let shadowOffsetHeig: Int = 3
        let shadowCol: UIColor? = UIColor.black
        let shadowOpaci: Float = 0.3
        
        layer.cornerRadius = cornerRad
        let shadowPa = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = shadowCol?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWid, height: shadowOffsetHeig);
        layer.shadowOpacity = shadowOpaci
        layer.shadowPath = shadowPa.cgPath
    }

}



