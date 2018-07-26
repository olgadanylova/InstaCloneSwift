
import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var post: Post?
    var postViewController: PostViewContoller?
    var liked = false
    var likesCount = 0
    
    private let LIKE = "like"
    private let LIKE_SELECTED = "likeSelected"
    private var postStore: IDataStore?
    private var likeStore: IDataStore?    

    override func awakeFromNib() {
        super.awakeFromNib()
        if (activityIndicator != nil && likeImageView != nil) {
            activityIndicator.isHidden = true
            let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLikeTap))
            likeImageView.addGestureRecognizer(likeTapGesture)
            likeImageView.isUserInteractionEnabled = true
            postStore = Backendless.sharedInstance().data.of(Post.ofClass())
            likeStore = Backendless.sharedInstance().data.of(Likee.ofClass())
        }        
    }
    
     @IBAction func handleLikeTap() {
        if (!liked) {
            liked = true
            likeImageView.image = UIImage(named: "likeSelected")
            likeStore?.save(Likee(), response: { like in
                    self.postStore!.addRelation("likes:Like:n", parentObjectId: self.post?.objectId, childObjects: [(like as! Likee).objectId!], response: { relationSet in
                        self.postStore?.find(byId: self.post?.objectId, response: { foundPost in
                            UIView.setAnimationsEnabled(false)
                            self.likeCountButton.setTitle(String(format: "%lu Likes", ((foundPost as! Post).likes?.count)!), for: .normal)
                            UIView.setAnimationsEnabled(true)
                        }, error: { fault in
                        })
                }, error: { fault in
                })
            }, error: { fault in
            })
        }
        else {
            liked = false
            likeImageView.image = UIImage(named: "like")
            let queryBuilder = DataQueryBuilder()!
            queryBuilder.setWhereClause(String(format: "ownerId = '%@'", Backendless.sharedInstance().userService.currentUser.objectId))
            likeStore?.findFirst(queryBuilder, response: { like in
                self.likeStore?.remove(like, response: { removed in
                    self.self.postStore?.find(byId: self.post?.objectId, response: { foundPost in
                        UIView.setAnimationsEnabled(false)
                        self.likeCountButton.setTitle(String(format: "%lu Likes", ((foundPost as! Post).likes?.count)!), for: .normal)
                        UIView.setAnimationsEnabled(true)
                    }, error: { fault in
                    })
                }, error: { fault in
                })
            }, error: { fault in
            })
        }        
    }
    
    func changeLikesButtonTitle() {
        likeCountButton.setTitle(String(format: "%li Likes", likesCount), for: .normal)
    }
    
    @IBAction func pressedEdit(_ sender: Any) {
        AlertViewController.sharedInstance.showEditAlert(post!, postViewController!)
    }
}

