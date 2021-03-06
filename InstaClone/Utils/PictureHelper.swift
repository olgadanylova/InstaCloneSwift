
import UIKit

class PictureHelper: NSObject {
    
    static let sharedInstance = PictureHelper()
    private let IMAGES_KEY = "instaCloneImages"
    
    func setProfilePicture(_ profilePicture: String, _ cell: UITableViewCell) {
        var image: UIImage?
        DispatchQueue.global().async {
            if (self.getImageFromUserDefaults(profilePicture) != nil) {
                image = self.getImageFromUserDefaults(profilePicture)
            }
            else {
                if let url = URL(string: profilePicture) {
                    do {
                        let data = try Data(contentsOf: url as URL)
                        image = UIImage(data: data)
                        self.saveImageToUserDefaults(image!, profilePicture)
                    } catch {
                    }
                }
            }
            DispatchQueue.main.async {
                if (cell.isKind(of: PostCell.ofClass())) {
                    (cell as! PostCell).profileImageView.image = image
                }
                else if (cell.isKind(of: LikeCell.ofClass())) {
                    (cell as! LikeCell).profileImageView.image = image
                }
                else if (cell.isKind(of: CommentCell.ofClass())) {
                    (cell as! CommentCell).profileImageView.image = image
                }
            }
        }
    }
    
    func setProfilePicture(_ profilePicture: String, _ header: UICollectionReusableView) {
        DispatchQueue.global().async {
            var image: UIImage?
            if (self.getImageFromUserDefaults(profilePicture) != nil) {
                image = self.getImageFromUserDefaults(profilePicture)
            }
            else {
                if let url = URL(string: profilePicture) {
                    do {
                        let data = try Data(contentsOf: url as URL)
                        image = UIImage(data: data)
                        self.saveImageToUserDefaults(image!, profilePicture)
                    } catch {
                    }
                }
            }
            DispatchQueue.main.async {
                if (header.isKind(of: ProfileHeaderCollectionReusableView.ofClass())) {
                    (header as! ProfileHeaderCollectionReusableView).profileImageView.image = image
                }
            }
        }
    }
    
    func setProfilePicture(_ profilePicture: String, _ imageView: UIImageView) {
        DispatchQueue.global().async {
            var image: UIImage?
            if (self.getImageFromUserDefaults(profilePicture) != nil) {
                image = self.getImageFromUserDefaults(profilePicture)
            }
            else {
                if let url = URL(string: profilePicture) {
                    do {
                        let data = try Data(contentsOf: url as URL)
                        image = UIImage(data: data)
                        self.saveImageToUserDefaults(image!, profilePicture)
                    } catch {
                    }
                }
            }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
    }
    
    func setPostPhoto(_ photo: String, _ cell: AnyObject) {
        if (cell.isKind(of: PostCell.ofClass())) {
            let postCell = cell as! PostCell
            DispatchQueue.global().async {
                var image: UIImage?
                if (self.getImageFromUserDefaults(photo) != nil) {
                    image = self.getImageFromUserDefaults(photo)
                }
                else {
                    DispatchQueue.main.async {
                        postCell.postImageView.image = nil
                        postCell.activityIndicator.isHidden = false
                        postCell.activityIndicator.startAnimating()
                    }
                    if let url = URL(string: photo) {
                        do {
                            let data = try Data(contentsOf: url as URL)
                            image = UIImage(data: data)
                            self.saveImageToUserDefaults(image!, photo)
                        } catch {
                        }
                    }
                }
                DispatchQueue.main.async {
                    postCell.postImageView.image = image
                    if (postCell.activityIndicator != nil) {
                        postCell.activityIndicator.stopAnimating()
                    }                    
                }
            }
        }
        else if (cell.isKind(of: PhotoCollectionViewCell.ofClass())) {
            let collectionViewCell = cell as! PhotoCollectionViewCell
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    collectionViewCell.photoImageView.image = nil
                }
                var image: UIImage?
                if (self.getImageFromUserDefaults(photo) != nil) {
                    image = self.getImageFromUserDefaults(photo)
                }
                else {
                    if let url = URL(string: photo) {
                        do {
                            let data = try Data(contentsOf: url as URL)
                            image = UIImage(data: data)
                            self.saveImageToUserDefaults(image!, photo)
                        } catch {
                        }
                    }
                }
                DispatchQueue.main.async {
                    collectionViewCell.photoImageView.image = image
                }
            }
        }
    }
    
    func scaleAndRotateImage(_ image: UIImage) -> UIImage {
        var changedImage = image
        changedImage = scaleImage(changedImage)
        changedImage = rotateImage(changedImage)
        return changedImage
    }
    
    func scaleImage(_ image: UIImage) -> UIImage {
        var imageWidth = image.size.width
        var imageHeight = image.size.height
        let maxSize = CGFloat(1080)
        if (imageWidth > maxSize && imageHeight > maxSize) {
            if (imageWidth >= imageHeight) {
                let coef = imageWidth / maxSize
                imageWidth = maxSize
                imageHeight = imageHeight / coef
            }
            else {
                let coef = imageHeight / maxSize
                imageHeight = maxSize
                imageWidth = imageWidth / coef
            }
        }
        let newSize = CGSize(width: imageWidth, height: imageHeight)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func rotateImage(_ image: UIImage) -> UIImage {
        if (image.imageOrientation == UIImage.Orientation.up) {
            return image;
        }
        var transform:CGAffineTransform = CGAffineTransform.identity
        if (image.imageOrientation == UIImage.Orientation.down || image.imageOrientation == UIImage.Orientation.downMirrored) {
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
        }
        if (image.imageOrientation == UIImage.Orientation.left || image.imageOrientation == UIImage.Orientation.leftMirrored) {
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        }
        if (image.imageOrientation == UIImage.Orientation.right || image.imageOrientation == UIImage.Orientation.rightMirrored) {
            transform = transform.translatedBy(x: 0, y: image.size.height);
            transform = transform.rotated(by: -(.pi / 2));
        }
        if (image.imageOrientation == UIImage.Orientation.upMirrored || image.imageOrientation == UIImage.Orientation.downMirrored) {
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        if (image.imageOrientation == UIImage.Orientation.leftMirrored || image.imageOrientation == UIImage.Orientation.rightMirrored) {
            transform = transform.translatedBy(x: image.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        let context: CGContext = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height),
                                           bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                           space: image.cgImage!.colorSpace!,
                                           bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!
        context.concatenate(transform)
        if (image.imageOrientation == UIImage.Orientation.left ||
            image.imageOrientation == UIImage.Orientation.leftMirrored ||
            image.imageOrientation == UIImage.Orientation.right ||
            image.imageOrientation == UIImage.Orientation.rightMirrored) {
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        }
        else {
            context.draw(image.cgImage!, in: CGRect(x:0, y:0, width:image.size.width, height:image.size.height))
        }
        let cgImage: CGImage = context.makeImage()!
        return UIImage(cgImage: cgImage)
    }
    
    func saveImageToUserDefaults(_ image: UIImage?, _ key: String) {
        if (image != nil) {
            if var data = UserDefaults.standard.object(forKey: IMAGES_KEY) {
                if var images = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? [String : Any] {
                    images[key] = image
                    data = NSKeyedArchiver.archivedData(withRootObject: images)
                    UserDefaults.standard.set(data, forKey: IMAGES_KEY)
                    UserDefaults.standard.synchronize()
                }
                else {
                    var images = [String : Any]()
                    images[key] = image
                    data = NSKeyedArchiver.archivedData(withRootObject: images)
                    UserDefaults.standard.set(data, forKey: IMAGES_KEY)
                    UserDefaults.standard.synchronize()
                }
            }
            else {
                var images = [String : Any]()
                images[key] = image
                let data = NSKeyedArchiver.archivedData(withRootObject: images)
                UserDefaults.standard.set(data, forKey: IMAGES_KEY)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func removeImageFromUserDefaults(_ key: String) {
        var data = UserDefaults.standard.object(forKey: IMAGES_KEY)
        var images = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? [String : Any]
        images?.removeValue(forKey: key)
        data = NSKeyedArchiver.archivedData(withRootObject: images as Any)
        UserDefaults.standard.set(data, forKey: IMAGES_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func getImageFromUserDefaults(_ key: String) -> UIImage? {
        if let data = UserDefaults.standard.object(forKey: IMAGES_KEY) {
            if let images = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? [String : Any] {
                if let image = images[key] as? UIImage {
                    return image
                }                
            }
        }
        return nil
    }
}

