//
//  StationFareTableViewCell.swift
//  KaohsiungMRT
//
//  Created by CHIA CHUN LI on 2021/3/30.
//

import UIKit

class StationFareTableViewCell: UITableViewCell {

    
    @IBOutlet weak var endStationNameLabel: UILabel!
    @IBOutlet weak var startStationNameLabel: UILabel!
    @IBOutlet weak var adultFareLabel: UILabel!
    @IBOutlet weak var studentFareLabel: UILabel!
    @IBOutlet weak var childFareLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
