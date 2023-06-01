//
//  SubVideosCollectionViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 12/05/2023.
//

import UIKit

class SubVideosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconCheckBoxImg: UIImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.borderWidth = 0.1
        imageView.layer.cornerRadius = 9
        blurView.layer.borderWidth = 0.1
        blurView.layer.cornerRadius = 9
        subImageView.layer.borderWidth = 0.05
        subImageView.layer.cornerRadius = 5
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

