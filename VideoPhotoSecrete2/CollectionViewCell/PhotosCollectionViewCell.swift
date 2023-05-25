//
//  PhotosCollectionViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 11/05/2023.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var checkBoxImgView: UIImageView!
    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        blurView.layer.borderWidth = 0.1
        blurView.layer.cornerRadius = 10
    }

    override var isHighlighted: Bool {
        didSet {
            blurView.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet {
            blurView.isHidden = !isSelected
            checkBoxImgView.isHidden = !isSelected
        }
    }
}
