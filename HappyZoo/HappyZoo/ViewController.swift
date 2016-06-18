//
//  ViewController.swift
//  HappyZoo
//
//  Created by 賢瑭 何 on 2016/6/13.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var animalData = [Animal]()
    var fileManager: NSFileManager?
    @IBOutlet weak var tableView: UITableView!
    var accessoryForIndexPath: Int?
    
    
    var thumbnailURL: [NSURL]? {
        if let manager = fileManager {
            let dic = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            return dic
        }else{
            return nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        Alamofire.request(.GET, Constants.jsonURL).validate().responseJSON { (response) in
            if response.result.isSuccess {
                if let value = response.result.value{
                    let json = JSON(value)
                    if let ary = json["result"]["results"].array {
                        for object in ary {
                            if let dic = object.dictionary {
                                let animal = Animal(data: dic)
                                if animal != nil {
                                    self.animalData.append(animal!)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }else {
                if response.result.isFailure {
                    if let error = response.result.error {
                        print("\(error.localizedDescription)")
                    }
                    print("result is failure")
                }
            }
        }

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return animalData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? CustomTableViewCell
        
        if !(animalData as Array).isEmpty {
            let index = indexPath.row
            let info = animalData[index]
            let url = NSURL(string: info.picImageURL)
            let qos = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
            let queue = dispatch_get_global_queue(qos, 0)
            
            if let imageURL = url {
                dispatch_async(queue, {
                    let imageData = NSData(contentsOfURL: imageURL)
                    dispatch_async(dispatch_get_main_queue(), {
                        if let data = imageData {
                            cell?.animalImage = UIImage(data: data)
                            self.saveImage(cell?.animalImage, index: index)
                            if let path = self.thumbnailURL?.first!.absoluteString {
                                cell?.animalImage = UIImage(contentsOfFile: path)
                            }
                        }else {
                            cell?.animalImage = UIImage(named: "wuimage")
                        }
                    })
                })
            }
            if cell?.accessoryView == nil {
                cell?.accessoryType = .DetailDisclosureButton
            }
            
            cell?.chName.text = info.chName
            return cell!
        }else {
            return UITableViewCell()
        }
    }
    
    func saveImage(thumbnail: UIImage?, index: Int) {
        if let image = thumbnail {
            if let imageJPEGData = UIImageJPEGRepresentation(image, 0.5) {
                fileManager = NSFileManager()
                if let dic = fileManager!.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                    let url = dic.URLByAppendingPathComponent("\(index).jpg")
                    imageJPEGData.writeToURL(url, atomically: true)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        accessoryForIndexPath = indexPath.row
        performSegueWithIdentifier("Show Image", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let index = accessoryForIndexPath {
            if segue.identifier == "Show Image" {
                if let dv = segue.destinationViewController as? ImageViewController {
                        dv.animal = animalData[index]
                        accessoryForIndexPath = nil
                }
            }
        }
    }
}