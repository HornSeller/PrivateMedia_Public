//
//  SubPhotosCollectionViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 11/05/2023.
//

import UIKit

class SubPhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.borderWidth = 0.1
        imageView.layer.cornerRadius = 15
    }
}
