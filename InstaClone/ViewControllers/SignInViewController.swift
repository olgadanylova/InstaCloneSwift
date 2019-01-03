
import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signInButton: UIButton!
    
    private let APP_ID = "61AE8EEB-EA13-15FB-FF48-9197C8FD0500"
    private let API_KEY = "77CCF20A-A5AB-FF09-FFFC-710027274900"
    private let HOST_URL = "http://api.backendless.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        emailField.tag = 0
        passwordField.tag = 1
        Backendless.sharedInstance().hostURL = HOST_URL
        Backendless.sharedInstance().initApp(APP_ID, apiKey: API_KEY)
        if (Backendless.sharedInstance().userService.isValidUserToken() && Backendless.sharedInstance().userService.currentUser != nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.showTabBar()
            })
        }
        else {
            Backendless.sharedInstance().userService.logout({
            }, error: { fault in
                if (fault?.faultCode == "404") {
                    AlertViewController.sharedInstance.showErrorAlertWithExit(self)
                }
                else {
                    AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) {
            nextTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func showTabBar() {
        performSegue(withIdentifier: "ShowTabBar", sender: nil)
    }
    
    @IBAction func pressedSignIn(_ sender: Any) {
        view.endEditing(true)
        if ((emailField.text?.count)! > 0 && (passwordField.text?.count)! > 0) {
            Backendless.sharedInstance().userService.setStayLoggedIn(true)
            let email = emailField.text
            let password = passwordField.text
            Backendless.sharedInstance().userService.login(email, password: password, response: { user in
                self.view.endEditing(true)
                self.emailField.text = ""
                self.passwordField.text = ""
                self.showTabBar()
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
            })
        }
        else {
            AlertViewController.sharedInstance.showErrorAlert("Please make sure you've entered your email and password correctly", self)
        }
    }
    
    @IBAction func pressedRestorePassword(_ sender: Any) {
        AlertViewController.sharedInstance.showRestorePasswordAlert(self)
    }
    
    @IBAction func pressedRegister(_ sender: Any) {
        performSegue(withIdentifier: "ShowSignUp", sender: nil)
    }
    
    @IBAction func unwindToSignIn(segue:UIStoryboardSegue) {
    }
}
