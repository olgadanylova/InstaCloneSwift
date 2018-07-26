
import UIKit

class LikesViewController: UITableViewController {
    
    var post: Post?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (post != nil) {
            return (post?.likes?.count)!
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeCell", for: indexPath) as! LikeCell
        let like = post?.likes![indexPath.row]
        Backendless.sharedInstance().userService.find(byId: like?.ownerId, response: { user in
            cell.nameLabel.text = String(format: "%@ liked this photo", (user?.name)!)
            PictureHelper.sharedInstance.setProfilePicture(user?.getProperty("profilePicture") as! String, cell)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
        return cell
    }
    
    @IBAction func pressedRefresh(_ sender: Any) {
        Backendless.sharedInstance().data.of(Post.ofClass()).find(byId: post?.objectId, response: { foundPost in
            self.post = foundPost as? Post
            self.tableView.reloadData()
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
    }
}
