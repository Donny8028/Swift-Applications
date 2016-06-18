//
//  WikiImageManager.swift
//  WikiFace
//
//  Created by 賢瑭 何 on 2016/5/30.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit

class WikiFaceRequest {
    let name: String
    
    init(fullName: String) {
        name = fullName
    }
    
    func fetchData(completionHandler: NSData? -> Void) {
        var imageData: NSData?
        var dataDic: [String:AnyObject]?
        getFaceData { (data, response, error) in
            if let urlData = data {
                do {
                    dataDic = try NSJSONSerialization.JSONObjectWithData(urlData, options: NSJSONReadingOptions.MutableContainers) as? [String:AnyObject]
                }catch{
                    fatalError("Can not parse the Json Data!")
                }
                if let jsonData = dataDic {
                    if let id = jsonData[WikiKey.query]![WikiKey.pages] as? [String:AnyObject] {
                        var dic = [String:AnyObject]()
                        for (_,value) in id {
                            dic = value as! [String:AnyObject]
                        }
                        let title = dic[WikiKey.title] as! String
                        if let thumbnailProp = dic[WikiKey.thumbnail] as? [String:AnyObject] {
                            let source = thumbnailProp[WikiKey.imageSource] as! String
                            let imageURL = NSURL(string: source)
                            imageData = NSData(contentsOfURL: imageURL!)
                            if imageData != nil && title == self.name {
                             completionHandler(imageData!)
                            }
                        }
                    }
                }
            }else{
                print("\(error?.localizedDescription)")
                return
            }
        }
    }
 
    private func getFaceData(completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void ) {
        let nameContents = name.componentsSeparatedByString(" ")
        guard nameContents.count > 0 else {
            print("Invalid name")
            return
        }
        let stringForContents = nameContents.joinWithSeparator("%20")
        let url = NSURL(string: WikiKey.URL + stringForContents)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
    }

    struct WikiKey {
        static let title = "title"
        static let query = "query"
        static let pages = "pages"
        static let imageSource = "source"
        static let width = "width"
        static let height = "height"
        static let thumbnail = "thumbnail"
        static let URL = "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=pageimages&continue=&piprop=thumbnail%7Cname&pithumbsize=600&titles="
    }
} 