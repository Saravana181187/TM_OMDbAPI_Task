//
//  MoviesTableCell.swift
//  TM_MachineTask
//
//  Created by Saravanakumar B on 6/16/22.
//

import UIKit

class MoviesTableCell: UITableViewCell {
    
    @IBOutlet weak var movieNameLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
