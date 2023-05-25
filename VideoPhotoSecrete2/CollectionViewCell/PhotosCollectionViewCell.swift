//
//  PhotosCollectionViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 11/05/2023.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkBoxImgView: UIImageView!
    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxImgView.isHidden = true
    }

}
