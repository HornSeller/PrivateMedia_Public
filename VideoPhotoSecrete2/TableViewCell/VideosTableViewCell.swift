//
//  VideosTableViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 12/05/2023.
//

import UIKit

class VideosTableViewCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var videoCountLb: UILabel!
    @IBOutlet var titleLb: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.layer.borderWidth = 0.1
        imgView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
