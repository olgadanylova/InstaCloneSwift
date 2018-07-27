
import UIKit

class PostViewContoller: UITableViewController, UITextViewDelegate {
    
    var post: Post?
    var editMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        if (!editMode) {
            navigationItem.hidesBackButton = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (post != nil) {
            if (section == 0 || section == 2) {
                return 1
            }
            else if (section == 1) {
                if (editMode) {
                    return 0
                }
                return 1
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostPhotoCell", for: indexPath) as! PostCell
            cell.post = post
            cell.postViewController = self
            Backendless.sharedInstance().userService.find(byId: post?.ownerId, response: { user in
                PictureHelper.sharedInstance.setProfilePicture(user?.getProperty("profilePicture") as! String, cell)
                cell.nameLabel.text = user?.name as String?
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
            })
            PictureHelper.sharedInstance.setPostPhoto((post?.photo)!, cell)
            return cell
        }
        else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostLikesAndCommentsCell", for: indexPath) as! PostCell
            cell.post = post
            UIView.setAnimationsEnabled(false)
            cell.likeCountButton.setTitle(String(format: "%lu Likes", (self.post?.likes?.count)!), for: .normal)
            UIView.setAnimationsEnabled(true)
            cell.likeCountButton.addTarget(self, action: #selector(likesButtonTapped(_:)), for: .touchUpInside)
            cell.commentsButton.addTarget(self, action: #selector(commentsButtonTapped(_:)), for: .touchUpInside)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm yyyy/MM/dd"
            cell.dateLabel.text = formatter.string(from: (post?.created)!)
            
            if(post?.likes?.filter({$0.ownerId == Backendless.sharedInstance().userService.currentUser.objectId as String}).first != nil) {
                cell.liked = true
                cell.likeImageView.image = UIImage(named: "likeSelected.png")
            }
            else {
                cell.liked = false
                cell.likeImageView.image = UIImage(named: "like.png")
            }
            return cell
        }
        else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCaptionCell", for: indexPath) as! PostCaptionCell
            cell.captionTextView.delegate = self
            cell.captionTextView.text = post?.caption
            if (editMode) {
                cell.captionTextView.isEditable = true
            }
            else {
                cell.captionTextView.isEditable = false
            }
            return cell
        }
        return UITableViewCell()
    }
    
    @IBAction func likesButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowLikes", sender: sender)
    }
    
    @IBAction func commentsButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowComments", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowLikes") {
            let likesVC = segue.destination as! LikesViewController
            likesVC.post = post
            likesVC.tableView.reloadData()
        }
        else if (segue.identifier == "ShowComments") {
            let commentsVC = segue.destination as! CommentsViewController
            commentsVC.post = post
            if (commentsVC.tableView != nil) {
                commentsVC.tableView.reloadData()
            }
        }
    }

    func scrollToTop() {
        let top = IndexPath(row: NSNotFound, section: 0)
        tableView.scrollToRow(at: top, at: .top, animated: true)
    }
    
    @IBAction func pressedSave(_ sender: Any) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! PostCaptionCell
        post?.caption = cell.captionTextView.text
        Backendless.sharedInstance().data.of(Post.ofClass()).save(post, response: { editedPost in
            self.editMode = false
            self.tableView.reloadData()
            self.navigationItem.title = nil
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.hidesBackButton = false
            self.scrollToTop()
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
    }
    
    @IBAction func pressedCancel(_ sender: Any) {
        editMode = false
        tableView.reloadData()
        navigationItem.title = nil
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = false
        scrollToTop()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        let lastIndex = IndexPath(row: 0, section: 2)
        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
    }
}
