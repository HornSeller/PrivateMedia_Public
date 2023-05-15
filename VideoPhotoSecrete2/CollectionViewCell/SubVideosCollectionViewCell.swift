//
//  SubVideosCollectionViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 12/05/2023.
//

import UIKit

class SubVideosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.borderWidth = 0.1
        imageView.layer.cornerRadius = 15
        subImageView.layer.borderWidth = 0.05
        subImageView.layer.cornerRadius = 5
    }

}

