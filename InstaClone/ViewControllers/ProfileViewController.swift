
import UIKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    private var totalUsersCount = 0
    var posts: [Post]?
    var postStore: IDataStore?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postStore = Backendless.sharedInstance().data.of(Post.ofClass())
        getUserPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.delegate = self
        getUserPosts()
    }
    
    func getUserPosts() {
        let queryBuilder = DataQueryBuilder()!
        queryBuilder.setWhereClause(String(format: "ownerId = '%@'", Backendless.sharedInstance().userService.currentUser.objectId))
        postStore?.find(queryBuilder, response: { userPosts in
            self.posts = (userPosts as! [Post]).sorted(by: { $0.created! > $1.created! })
            Backendless.sharedInstance().data.of(BackendlessUser.ofClass()).getObjectCount({ usersCount in
                self.totalUsersCount = (usersCount?.intValue)!
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet.init(integer: 0))
                }, completion: nil)
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
            })
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        scrollToTop()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (posts != nil) {
            return (posts?.count)!
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.post = posts?[indexPath.row]
        PictureHelper.sharedInstance.setPostPhoto((cell.post?.photo)!, cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeaderCollectionReusableView", for: indexPath) as! ProfileHeaderCollectionReusableView
        headerViewCell.user = Backendless.sharedInstance().userService.currentUser
        if (posts != nil) {
            headerViewCell.postsCountLabel.text = String(format: "%lu", (posts?.count)!)
        }        
        if (totalUsersCount > 0) {
            headerViewCell.followingCountLabel.text = String(format: "%li", totalUsersCount - 1)
            headerViewCell.followersCountLabel.text = String(format: "%li", totalUsersCount - 1)
        }
        return headerViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPost", sender: posts?[indexPath.row])
    }
    
    func scrollToTop() {
        let navBarHeight = navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let point = CGPoint(x: 0, y: 0 - statusBarHeight - navBarHeight!)
        collectionView.setContentOffset(point, animated: true)
    }
    
    @IBAction func pressedRefresh(_ sender: Any) {
        getUserPosts()
        scrollToTop()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowPost") {
            let postVC = segue.destination as! PostViewContoller
            postVC.post = sender as? Post
            postVC.editMode = false
            postVC.tableView.reloadData()
        }
    }
    
    @IBAction func unwindToProfile(segue:UIStoryboardSegue) {
        getUserPosts()
    }
}
