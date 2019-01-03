
import UIKit
import MobileCoreServices

class EditProfileViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentUser: BackendlessUser?
    private var profileImageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameField.delegate = self
        let side = profileImageView.frame.size.width / 2
        profileImageView.frame = CGRect(x: 0, y: 0, width: side, height: side)
        profileImageView.layer.cornerRadius = side
        activityIndicator.isHidden = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapImageView)))
        currentUser = Backendless.sharedInstance().userService.currentUser
        profileImageChanged = false
        PictureHelper.sharedInstance.setProfilePicture(currentUser?.getProperty("profilePicture") as! String, profileImageView)
        userNameField.text = currentUser?.name as String?
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func tapImageView() {
        AlertViewController.sharedInstance.showTakePhotoAlert(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String {
            if (mediaType == kUTTypeImage as String) {
                if  (picker.sourceType == .camera) {
                    let imageTaken = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
                    UIImageWriteToSavedPhotosAlbum(imageTaken, nil, nil, nil)
                    profileImageView.image = imageTaken
                    picker.dismiss(animated: true, completion: nil)
                }
                else {
                    let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
                    profileImageView.image = image
                    picker.dismiss(animated: true, completion: nil)
                }
                 profileImageChanged = true
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedCancel(_ sender: Any) {
        performSegue(withIdentifier: "unwindToProfileVC", sender: nil)
    }
    
    @IBAction func pressedRestorePassword(_ sender: Any) {
        AlertViewController.sharedInstance.showRestorePasswordAlert(self)
    }
    
    @IBAction func pressedSave(_ sender: Any) {
        view.endEditing(true)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        if (currentUser?.name as String? != userNameField.text) {
            currentUser?.name = userNameField.text as NSString?
        }
        if (profileImageChanged) {
            var profilePicture = currentUser?.getProperty("profilePicture") as! String
            if let range = profilePicture.range(of: "InstaCloneProfilePictures") {
                profilePicture = String(profilePicture[range.lowerBound...])
                Backendless.sharedInstance().file.remove(profilePicture, response: { removed in
                    PictureHelper.sharedInstance.removeImageFromUserDefaults(profilePicture)
                    let profileImageFileName = String(format: "/InstaCloneProfilePictures/%@.png", UUID().uuidString)
                    let image = PictureHelper.sharedInstance.scaleAndRotateImage(self.profileImageView.image!)
                    let data = image.pngData()
                    PictureHelper.sharedInstance.saveImageToUserDefaults(image, profileImageFileName)
                    Backendless.sharedInstance().file.uploadFile(profileImageFileName, content: data, response: { uplaodedProfilePicture in
                        self.currentUser?.setProperty("profilePicture", object: uplaodedProfilePicture?.fileURL)
                        Backendless.sharedInstance().data.ofTable("Users").save(self.currentUser, response: { updatedUser in
                            AlertViewController.sharedInstance.showUpdateCompleteAlert(self)
                        }, error: { fault in
                            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                        })
                    }, error: { fault in
                        AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                    })
                }, error: { fault in
                    AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                })
            }
        }
        else {
            Backendless.sharedInstance().data.ofTable("Users").save(currentUser, response: { updatedUser in
                AlertViewController.sharedInstance.showUpdateCompleteAlert(self)
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
            })
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
