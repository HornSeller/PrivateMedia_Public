//
//  SubDocumentsTableViewCell.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 16/05/2023.
//

import UIKit

class SubDocumentsTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var sizeLb: UILabel!
    @IBOutlet weak var dateLb: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
