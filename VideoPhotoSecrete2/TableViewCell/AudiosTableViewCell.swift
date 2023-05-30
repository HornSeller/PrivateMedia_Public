//
//  AudiosTableViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 18/05/2023.
//

import UIKit

class AudiosTableViewCell: UITableViewCell {

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
