//
//  TableViewCell.swift
//  TextRocognition
//  Класс данных ячейки
//  Created by User on 21/05/2019.
//  Copyright © 2019 User. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var fromString: UILabel!
    @IBOutlet weak var toString: UILabel!
    @IBOutlet weak var translateMode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
