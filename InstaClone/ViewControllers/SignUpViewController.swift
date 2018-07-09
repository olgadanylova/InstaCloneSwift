
import UIKit
import MobileCoreServices

class SignUpViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        userNameField.tag = 0
        emailField.tag = 1
        passwordField.tag = 2
        let side = profileImageView.frame.size.width / 2
        profileImageView.frame = CGRect(x: 0, y: 0, width: side, height: side)
        profileImageView.layer.cornerRadius = side
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImageView)))
        activityIndicator.isHidden = true
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
    
    @IBAction func tapImageView() {
        AlertViewController.sharedInstance.showTakePhotoAlert(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if (mediaType == kUTTypeImage as String) {
                if  (picker.sourceType == .camera) {
                    let imageTaken = info[UIImagePickerControllerOriginalImage] as! UIImage
                    UIImageWriteToSavedPhotosAlbum(imageTaken, nil, nil, nil)
                    profileImageView.image = imageTaken
                    picker.dismiss(animated: true, completion: nil)
                }
                else {
                    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                    profileImageView.image = image
                    picker.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedSignUp(_ sender: Any) {
        view.endEditing(true)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        if ((userNameField.text?.count)! > 0 && (emailField.text?.count)! > 0 && (passwordField.text?.count)! > 0) {
            let newUser = BackendlessUser()
            newUser.name = userNameField.text as NSString?
            newUser.email = emailField.text as NSString?
            newUser.password = passwordField.text as NSString?
            if (profileImageView.image?.imageAsset?.value(forKey: "assetName") as? String != "camera") {
                let profileImageFileName = String(format: "/InstaCloneProfilePictures/%@.png", UUID().uuidString)
                let image = PictureHelper.sharedInstance.scaleImage(profileImageView.image!)
                let data = UIImagePNGRepresentation(image)
                PictureHelper.sharedInstance.saveImageToUserDefaults(image, profileImageFileName)
                Backendless.sharedInstance().file.uploadFile(profileImageFileName, content: data, response: { profilePicture in
                    newUser.setProperty("profilePicture", object: profilePicture?.fileURL)
                    Backendless.sharedInstance().userService.register(newUser, response: { user in
                        self.activityIndicator.stopAnimating()
                        AlertViewController.sharedInstance.showSegueAlert(self, { action in
                            self.performSegue(withIdentifier: "unwindToSignInVC", sender: nil)
                        })
                    }, error: { fault in
                        self.activityIndicator.stopAnimating()
                        AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                    })
                }, error: { fault in
                    self.activityIndicator.stopAnimating()
                    AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                })
            }
            else {
                let defaultProfilePictureUrl = String(format: "https://api.backendless.com/%@/%@/files/InstaCloneProfilePictures/defaultProfilePicture.png", Backendless.sharedInstance().appID, Backendless.sharedInstance().apiKey)
                newUser.setProperty("profilePicture", object: defaultProfilePictureUrl)
                Backendless.sharedInstance().userService.register(newUser, response: { user in
                    self.activityIndicator.stopAnimating()
                    AlertViewController.sharedInstance.showSegueAlert(self, { action in
                        self.performSegue(withIdentifier: "unwindToSignInVC", sender: nil)
                    })
                }, error: { fault in
                    self.activityIndicator.stopAnimating()
                    AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                })
            }
        }
        else {
            self.activityIndicator.stopAnimating()
            AlertViewController.sharedInstance.showErrorAlert("Please make sure you've entered your name, email and password correctly", self)
        }
    }
    
    @IBAction func pressedDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
