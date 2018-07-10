
import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    var user: BackendlessUser? {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        nameLabel.text = user?.name as String?
        PictureHelper.sharedInstance.setProfilePicture(user?.getProperty("profilePicture") as! String, self)
    }
}
