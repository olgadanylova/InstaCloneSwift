
import UIKit
import MobileCoreServices

class CameraViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var captionTextView: UITextView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var clearButton: UIBarButtonItem!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    private let SHARE = "Share"
    private let TAKE_PHOTO = "Take a photo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultView()
        captionTextView.delegate = self
        captionTextView.tag = 0
    }
    
    func setDefaultView() {
        activityIndicator.isHidden = true
        photoImageView.isUserInteractionEnabled = false
        photoImageView.isHidden = true
        captionTextView.isUserInteractionEnabled = false
        captionTextView.isHidden = true
        captionTextView.text = ""
        clearButton.isEnabled = false
        clearButton.tintColor = UIColor.clear
        shareButton.setTitle(TAKE_PHOTO, for: .normal)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        photoImageView.isUserInteractionEnabled = true
        photoImageView.isHidden = false
        captionTextView.isUserInteractionEnabled = true
        captionTextView.isHidden = false
        clearButton.isEnabled = true
        clearButton.tintColor = getColorFromHex("2C3E50", 1)
        shareButton.setTitle(SHARE, for: .normal)
        if let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String {
            if (mediaType == kUTTypeImage as String) {
                if  (picker.sourceType == .camera) {
                    let imageTaken = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
                    UIImageWriteToSavedPhotosAlbum(imageTaken, nil, nil, nil)
                    photoImageView.image = imageTaken
                    picker.dismiss(animated: true, completion: nil)
                }
                else {
                    let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
                    photoImageView.image = image
                    picker.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func takePhoto() {
        if (shareButton.titleLabel?.text == TAKE_PHOTO) {
            view.endEditing(true)
            AlertViewController.sharedInstance.showTakePhotoAlert(self)
        }
    }
    
    func share() {
        if (shareButton.titleLabel?.text != TAKE_PHOTO) {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            let photoFileName = String(format: "/InstaClonePhotos/%@.png", UUID().uuidString)
            let image = PictureHelper.sharedInstance.scaleImage(photoImageView.image!)
            let data = image.pngData()
            PictureHelper.sharedInstance.saveImageToUserDefaults(image, photoFileName)
            Backendless.sharedInstance().file.uploadFile(photoFileName, content: data, response: { photo in
                let newPost = Post()
                newPost.photo = photo?.fileURL
                newPost.caption = self.captionTextView.text
                let postStore = Backendless.sharedInstance().data.of(Post.ofClass())
                postStore?.save(newPost, response: { post in
                    self.activityIndicator.stopAnimating()
                    self.setDefaultView()
                    self.performSegue(withIdentifier: "unwindToHomeVC", sender: nil)
                }, error: { fault in
                    AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                })
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
            })
        }
    }
    
    func getColorFromHex(_ hexColor: String, _ alpha:CGFloat) -> UIColor {
        var rgbValue: UInt32 = 0
        let scanner = Scanner.init(string: hexColor)
        scanner.scanLocation = 1 // bypass '#' character
        scanner.scanHexInt32(&rgbValue)
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
    
    @IBAction func pressedShare(_ sender: Any) {
        takePhoto()
        share()
    }
    
    @IBAction func pressedClear(_ sender: Any) {
        setDefaultView()
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
