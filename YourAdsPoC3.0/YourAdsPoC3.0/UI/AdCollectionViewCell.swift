//
//  CollectionViewCell.swift
//  YourAdsPoC3.0
//
//  Created by Cris Toozs on 29/09/2018.
//  Copyright © 2018 Cris Toozs. All rights reserved.
//

import UIKit

class AdCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var adName: UILabel!
    
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
