
import UIKit

@objcMembers
class Post: NSObject {
    var photo: String?
    var caption: String?
    var likes: [Likee]?
    var comments: [Comment]?
    var created: Date?
    var objectId: String?
    var ownerId: String?
}
