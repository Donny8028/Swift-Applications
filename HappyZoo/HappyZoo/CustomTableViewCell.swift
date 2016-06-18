//
//  CustomTableViewCell.swift
//  HappyZoo
//
//  Created by 賢瑭 何 on 2016/6/13.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var chName: UILabel!
    @IBOutlet weak var engName: UILabel!
    
    
    
    var animalImage: UIImage? {
        didSet{
            if let image = animalImage {
                if let view = thumbnail {
                    view.image = image
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
