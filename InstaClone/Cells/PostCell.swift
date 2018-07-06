
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
        activityIndicator.isHidden = true
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLikeTap))
        likeImageView.addGestureRecognizer(likeTapGesture)
        likeImageView.isUserInteractionEnabled = true
        postStore = Backendless.sharedInstance().data.of(Post.ofClass())
        likeStore = Backendless.sharedInstance().data.of(Likee.ofClass())
    }
    
    @objc func handleLikeTap() {
        
        if (!liked) {
            liked = true
            likeImageView.image = UIImage(named: "likeSelected")
            likeStore?.save(Likee(), response: { like in
               
                
            }, error: { fault in
                
            })
        }
        
        /*__weak PostCell *weakSelf = self;
         __weak id<IDataStore> weakPostStore = postStore;
         if (!self.liked) {
         self.liked = YES;
         self.likeImageView.image = [UIImage imageNamed:@"likeSelected"];
         [likeStore save:[Likee new] response:^(Likee *like) {
         [self->postStore addRelation:@"likes:Like:n"
         parentObjectId:self.post.objectId
         childObjects:@[like.objectId]
         response:^(NSNumber *relationSet) {
         [weakPostStore findById:weakSelf.post.objectId response:^(Post *post) {
         [UIView setAnimationsEnabled:NO];
         dispatch_async(dispatch_get_main_queue(), ^{
         [weakSelf.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", [post.likes count]] forState:UIControlStateNormal];
         });
         
         [UIView setAnimationsEnabled:YES];
         } error:^(Fault *fault) {
         }];
         } error:^(Fault *fault) {
         }];
         } error:^(Fault *fault) {
         }];
         }
         else {
         self.liked = NO;
         self.likeImageView.image = [UIImage imageNamed:@"like"];
         DataQueryBuilder *queryBuilder = [DataQueryBuilder new];
         [queryBuilder setWhereClause:[NSString stringWithFormat:@"ownerId = '%@'", backendless.userService.currentUser.objectId]];
         [likeStore findFirst:queryBuilder response:^(Likee *like) {
         [self->likeStore remove:like response:^(NSNumber *removed) {
         [self->postStore findById:self.post.objectId response:^(Post *post) {
         [UIView setAnimationsEnabled:NO];
         dispatch_async(dispatch_get_main_queue(), ^{
         [self.likeCountButton setTitle:[NSString stringWithFormat:@"%lu Likes", [post.likes count]] forState:UIControlStateNormal];
         });
         [UIView setAnimationsEnabled:YES];
         } error:^(Fault *fault) {
         }];
         } error:^(Fault *fault) {
         }];
         } error:^(Fault *fault) {
         }];
         }*/
        
    }
    
    func changeLikesButtonTitle() {
        likeCountButton.setTitle(String(format: "%li Likes", likesCount), for: .normal)
    }
}

