
import UIKit

class AlertViewController: UIViewController {
    
    static let sharedInstance = AlertViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showErrorAlert(_ message: String, _ target: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlertWithExit(_ target: UIViewController) {
        let alert = UIAlertController(title: "Error", message: "Make sure to configure the app with your APP ID and API KEY before running the app. \nApplication will be closed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
            exit(0)
        }))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showTakePhotoAlert(_ target: UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Use camera", style: .default, handler: { action in
            if (!UIImagePickerController.isSourceTypeAvailable(.camera)) {
                self.showErrorAlert("Camera is not available", target)
            }
            else {
                let cameraPicker = UIImagePickerController()
                cameraPicker.sourceType = .camera
                cameraPicker.delegate = target as! (UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate)
                target.present(cameraPicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Use Photo Library", style: .default, handler: { action in
            let photoPicker = UIImagePickerController()
            photoPicker.sourceType = .photoLibrary
            photoPicker.delegate = target as! (UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate)
            target.present(photoPicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showSegueAlert(_ target: UIViewController, _ action: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "Registration complete", message: "Please login to continue", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: action))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showRestorePasswordAlert(_ target: UIViewController) {
        let alert = UIAlertController(title: "Restore password", message: "Please enter your email address. Then check your inbox to restore the password", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "your email"
            textField.clearButtonMode = .whileEditing
        })
        alert.addAction(UIAlertAction(title: "Restore", style: .default, handler: { action in
            target.view.endEditing(true)
            let emailField = alert.textFields![0]
            Backendless.sharedInstance().userService.restorePassword(emailField.text, response: {
            }, error: { fault in
                self.showErrorAlert(fault!.message, target)
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            target.view.endEditing(true)
        }))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showUpdateCompleteAlert(_ target: UIViewController) {
        let alert = UIAlertController(title: "Profile updated", message: "Your profile has been successfully updated", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            target.performSegue(withIdentifier: "unwindToProfileVC", sender: nil)
        }))
        target.present(alert, animated: true, completion: nil)
    }
    
    func showEditAlert(_ post: Post, _ target: UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
            if (target.isKind(of: PostViewContoller.ofClass())) {
                let postVC = target as! PostViewContoller
                postVC.editMode = true
                postVC.tableView.reloadData()
                
                let indexPath = IndexPath(row: 0, section: 2)
                let cell = postVC.tableView.cellForRow(at: indexPath) as! PostCaptionCell
                cell.captionTextView.becomeFirstResponder()
                
                postVC.navigationItem.title = "Edit post"
                let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: postVC, action: #selector(postVC.pressedCancel(_:)))
                postVC.navigationItem.leftBarButtonItem = cancelButton
                let saveButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: postVC, action: #selector(postVC.pressedSave(_:)))
                postVC.navigationItem.rightBarButtonItem = saveButton
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            let confirmAlert = UIAlertController(title: "Delete post", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                Backendless.sharedInstance().data.of(Post.ofClass()).remove(post, response: { deleted in
                    if (target.isKind(of: PostViewContoller.ofClass())) {
                        target.performSegue(withIdentifier: "unwindToProfileVC", sender: nil)
                    }
                }, error: { fault in
                    self.showErrorAlert(fault!.message, target)
                })
            }))
            confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            target.present(confirmAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        target.present(alert, animated: true, completion: nil)
    }
}
