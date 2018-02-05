//
//  AlamofireSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 14.01.16.
//
//

import Alamofire
import AlamofireImage
 
//Default placeholderImage
private var defaultUrl: String {
    return (Bundle.main.url(forResource: "placeholderImage",withExtension:".png")?.relativePath)!
}
private let lightGrayColor = UIColor.init(red: 213/255, green: 213/255, blue: 215/255, alpha: 1.0)

/// Input Source to image using Alamofire
@objcMembers
public class AlamofireSource: NSObject, InputSource {
    /// url to load
    public var url: URL
    public var frame:CGRect?
    
    /// placeholder used before image is loaded
    public var placeholder: UIImage?

    /// Initializes a new source with a URL
    /// - parameter url: a url to load
    /// - parameter placeholder: a placeholder used before image is loaded
    public init(url: URL, placeholder: UIImage? = nil) {
        self.url = url
        self.placeholder = placeholder
        super.init()
    }

    /// Initializes a new source with a URL string
    /// - parameter urlString: a string url to load
    /// - parameter placeholder: a placeholder used before image is loaded
    public init?(urlString: String, placeholder: UIImage? = nil) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            self.placeholder = placeholder
            super.init()
        } else {
            return nil
        }
    }

    public func cancelLoad(on imageView: UIImageView) {
        imageView.af_cancelImageRequest()
    }
    
    open func getURLString() -> String {
        if isExternalURL() {
            return self.url.absoluteString
        } else {
            return self.url.relativePath
        }
    }
    open func getURL() -> URL {
        return url
    }
    open func isExternalURL() -> Bool {
        return self.url.absoluteString.contains("https://") ||
            self.url.absoluteString.contains("http://")
    }
    open func setToImageView(_ imageView: UIImageView) {
        if self.isExternalURL() {
            setExternalImage(imageView)
        } else {
            setLocalImage(imageView)
        }
    }
    
    fileprivate func setExternalImage(_ imageView:UIImageView) {
        guard let uFrame = self.frame else {
            imageView.af_setImage(withURL:url, placeholderImage: UIImage(), filter: nil, imageTransition:.crossDissolve(0.5), runImageTransitionIfCached: false, completion:{ response in
            })
            return
        }
        
        if url.absoluteString == defaultUrl {
            imageView.image = UIImage()
        } else {
            imageView.af_setImage(withURL:url, placeholderImage: UIImage(), filter: nil, imageTransition:.crossDissolve(0.5), runImageTransitionIfCached: false, completion:{ response in
                
                switch(response.result) {
                case .success(let image):
                    break
                case .failure(let error):
                    print(error)
                default:
                    break
                }
            })
        }
    }
    
    fileprivate func setLocalImage(_ imageView:UIImageView) {
        let image = UIImage(contentsOfFile: self.getURLString())
        imageView.image = image
    }
    
    open func setImageViewFrame(_ frame:CGRect) {
        self.frame = frame
    }
    
    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        //MARK:- UIColor.lightGray Chanage By Simform
        imageView.backgroundColor = lightGrayColor
        imageView.af_setImage(withURL: self.url, placeholderImage: nil, filter: nil, progress: nil) { (response) in
            if let value = response.result.value {
                imageView.image = response.result.value
                callback(value)
            } else {
                imageView.image = self.getImageWithColor(lightGrayColor, size: imageView.frame.size)
            }
            
        }
    }
    
    private func getImageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    
}
