//
//  Animal.swift
//  HappyZoo
//
//  Created by 賢瑭 何 on 2016/6/13.
//  Copyright © 2016年 Donny. All rights reserved.
//

import Foundation
import SwiftyJSON

class Animal {
    let chName: String
    let engName: String
    let destription: String
    let picImageURL: String
    let detail: String
    init?(data: [String:JSON]?) {
        if let animaldata = data {
            chName = animaldata[Constants.chName]!.stringValue
            engName = animaldata[Constants.engName]!.stringValue
            destription = animaldata[Constants.picDescription]!.stringValue
            picImageURL = animaldata[Constants.picURL]!.stringValue
            detail = animaldata[Constants.animalDetail]!.stringValue
        }else {
            return nil
        }
    }
}