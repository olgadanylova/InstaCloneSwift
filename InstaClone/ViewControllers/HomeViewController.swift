
import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    private var postStore: IDataStore?
    private var posts: [Post]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 550
        tableView.rowHeight = UITableView.automaticDimension
        postStore = Backendless.sharedInstance().data.of(Post.ofClass())
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
        scrollToTop()
        tabBarController?.delegate = self
        tabBarController?.tabBar.isHidden = false
    }
    
    func loadPosts() {
        postStore?.find({ postsFound in
            self.posts = (postsFound as! [Post]).sorted(by: { $0.created! > $1.created! })
            self.tableView.reloadData()
            self.scrollToTop()
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
    }
    
    func scrollToTop() {
        let top = IndexPath(row: NSNotFound, section: 0)
        tableView.scrollToRow(at: top, at: .top, animated: true)
    }
    
    @IBAction func likesButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowLikes", sender: sender)
    }
    
    @IBAction func commentsButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowComments", sender: sender)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (posts != nil) {
            return (posts?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = posts![indexPath.row]
        cell.post = post
        
        Backendless.sharedInstance().userService.find(byId: post.ownerId, response: { user in
            PictureHelper.sharedInstance.setProfilePicture(user?.getProperty("profilePicture") as! String, cell)
            cell.nameLabel.text = user?.name as String?
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
        PictureHelper.sharedInstance.setPostPhoto(post.photo!, cell)
        
        UIView.setAnimationsEnabled(false)
        cell.likeCountButton.setTitle(String(format: "%lu Likes", (post.likes?.count)!), for: .normal)
        UIView.setAnimationsEnabled(true)
        cell.likeCountButton.addTarget(self, action: #selector(likesButtonTapped(_:)), for: .touchUpInside)
        cell.commentsButton.addTarget(self, action: #selector(commentsButtonTapped(_:)), for: .touchUpInside)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm yyyy/MM/dd"
        cell.dateLabel.text = formatter.string(from: post.created!)
        
        if (post.likes?.filter({$0.ownerId == Backendless.sharedInstance().userService.currentUser.objectId as String}).first != nil) {
            cell.liked = true
            cell.likeImageView.image = UIImage(named: "likeSelected.png")
        }
        else {
            cell.liked = false
            cell.likeImageView.image = UIImage(named: "like.png")
        }
        cell.captionLabel.text = post.caption
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowLikes") {
            if let cell = (sender as! UIButton).superview?.superview as? PostCell {
                let indexPath = tableView.indexPath(for: cell)
                let likesVC = segue.destination as! LikesViewController
                likesVC.post = posts?[(indexPath?.row)!]
                likesVC.tableView.reloadData()
            }
        }
        else if (segue.identifier == "ShowComments") {
            if let cell = (sender as! UIButton).superview?.superview as? PostCell {
                let indexPath = tableView.indexPath(for: cell)
                let commentsVC = segue.destination as! CommentsViewController
                commentsVC.post = posts?[(indexPath?.row)!]
                if (commentsVC.tableView != nil) {
                    commentsVC.tableView.reloadData()
                }                
            }
        }
    }
    
    @IBAction func pressedLogout(_ sender: Any) {
        Backendless.sharedInstance().userService.logout({
            self.performSegue(withIdentifier: "unwindToSignIn", sender: nil)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
    }
    
    @IBAction func pressedRefresh(_ sender: Any) {
        loadPosts()
        scrollToTop()
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) {
    }
}
