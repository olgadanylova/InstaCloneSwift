
import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    var user: BackendlessUser?
    
    @IBAction func pressedEditProfile(_ sender: Any) {
    }
}
