//
//  AlbumTableViewCell.swift
//  Album
//
//  Created by nju on 2021/12/21.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var objectType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
