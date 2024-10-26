//
//  Utility.swift
//  TStore
//
//  Created by Thiruvazhagan S on 25/09/24.
//
import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private var imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check if the image is already cached
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // If not cached, download it
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the downloaded image
            self.imageCache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
