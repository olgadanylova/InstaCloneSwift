
import UIKit

class CommentsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var post: Post?
    private var postStore: IDataStore?
    private var commentStore: IDataStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        commentTextField.delegate = self
        commentTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        postStore = Backendless.sharedInstance().data.of(Post.ofClass())
        commentStore = Backendless.sharedInstance().data.of(Comment.ofClass())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false;
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func keyboardDidShow(_ notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        UIView.animate(withDuration: 0.3, animations: {
            var f = self.view.frame
            f.origin.y = -keyboardSize.height
            self.view.frame = f
        })
    }
    
    @IBAction func keyboardWillBeHidden(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
            var f = self.view.frame
            f.origin.y = 0
            self.view.frame = f
        })
    }
    
    @IBAction func textFieldDidChange() {
        if ((commentTextField.text?.count)! > 0) {
            sendButton.isEnabled = true
        }
        else {
            sendButton.isEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (post != nil) {
            return (post?.comments?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        post?.comments?.sort(by: { $0.created! > $1.created! })
        let comment = post?.comments![indexPath.row]
        Backendless.sharedInstance().userService.find(byId: comment?.ownerId, response: { user in
            PictureHelper.sharedInstance.setProfilePicture(user?.getProperty("profilePicture") as! String, cell)
            cell.nameLabel.text = user?.name as String?
            cell.commentLabel.text = comment?.text
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm yyyy/MM/dd"
            cell.dateLabel.text = formatter.string(from: (comment?.created!)!)
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let comment = post?.comments![indexPath.row]
            if (comment?.ownerId == Backendless.sharedInstance().userService.currentUser.objectId as String ||
                post?.ownerId == Backendless.sharedInstance().userService.currentUser.objectId as String) {
                commentStore?.remove(comment, response: { removed in
                self.reloadTableData()
                }, error: { fault in
                    AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
                })
            }
            else {
                AlertViewController.sharedInstance.showErrorAlert("Only the owner of this post or the person who left this comment delete it", self)
            }
        }
    }
    
    func reloadTableData() {
        postStore?.find(byId: post?.objectId, response: { foundPost in
            self.post = foundPost as? Post
            self.tableView.reloadData()
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
    }
    
    @IBAction func pressedSend(_ sender: Any) {
        let newComment = Comment()
        newComment.text = commentTextField.text
        commentStore?.save(newComment, response: { comment in
            self.postStore!.addRelation("comments:Comment:n", parentObjectId: self.post?.objectId, childObjects: [(comment as! Comment).objectId!], response: { relationSet in
                self.commentTextField.text = ""
                self.sendButton.isEnabled = false
                self.view.endEditing(true)
                self.reloadTableData()
            }, error: { fault in
                AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
            })
        }, error: { fault in
            AlertViewController.sharedInstance.showErrorAlert(fault!.message, self)
        })
    }
    
    @IBAction func pressedRefresh(_ sender: Any) {
        reloadTableData()
    }    
}





























