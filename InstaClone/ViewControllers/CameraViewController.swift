
import UIKit

class CameraViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var captionTextView: UITextView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var clearButton: UIBarButtonItem!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pressedShare(_ sender: Any) {
    }
    
    @IBAction func pressedClear(_ sender: Any) {
    }
}
