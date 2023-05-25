//
//  SubPhotosCollectionViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 25/05/2023.
//

import UIKit

class SubPhotosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconCheckBoxImg: UIImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.borderWidth = 0.1
        imageView.layer.cornerRadius = 15
        blurView.layer.borderWidth = 0.1
        blurView.layer.cornerRadius = 15
    }

    override var isHighlighted: Bool {
        didSet {
            blurView.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet {
            blurView.isHidden = !isSelected
            iconCheckBoxImg.isHidden = !isSelected
        }
    }
}
