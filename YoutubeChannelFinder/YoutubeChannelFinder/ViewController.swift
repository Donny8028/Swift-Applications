//
//  ViewController.swift
//  YoutubeChannelFinder
//
//  Created by 賢瑭 何 on 2016/6/14.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segControlView: UISegmentedControl!
    @IBOutlet weak var searchTextFiled: UITextField!

    private let apiKey = "Your Google ApiKey"
    var channels = ["Apple","Google","MicroSoft","amazon"]
    var channelNameWithid = [String:[String:String]]()
    var playlist = [[String:String]]()
    var playlistWithAttribute = [String:[String:String]]()
    var channelIndex = 0
    var didTapAtIndex: Int?
    var searchStatus = false
    var didSearchVideo = false
    var lastSearchVideoName = "Apple"
    var lastSearchChannelName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchTextFiled.delegate = self
        view.bringSubviewToFront(activityView)
        activityView.hidden = true
        
        let titleView = UILabel(frame:CGRect(x: 0.0, y: 0.0, width: 100, height: 30))
        titleView.text = "Youtube channel finder"
        titleView.textColor = UIColor.whiteColor()
        titleView.lineBreakMode = .ByWordWrapping
        
        self.navigationItem.titleView = titleView
        getData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        activityView.frame = view.frame
    }
    
    @IBAction func segmentAction(sender: UISegmentedControl) {
        if searchStatus {
            if segControlView.selectedSegmentIndex == 1 {
                searchTextFiled.text = lastSearchVideoName
            }else {
                searchTextFiled.text = lastSearchChannelName ?? ""
            }
        }else {
            if segControlView.selectedSegmentIndex == 1 {
                searchTextFiled.text = lastSearchVideoName
            }else {
                searchTextFiled.text = nil
            }
        }
        
        getData()
    }

    // - MARK: Get Data
    
    func getData() {
        
        activityView.hidden = false
        
        let index = segControlView.selectedSegmentIndex
        let status = searchStatus
        let situation = (index,status)
        
        switch situation {
            
        case (0, true):
            
            if searchTextFiled.text != lastSearchChannelName {
                    getSearchData(searchStatus)
                }else {
                    getChannelData()
                }
            
        case (0, false):
            
            getChannelData()
            
        case (1, true):
            
            if searchTextFiled.text != lastSearchVideoName {
                getSearchData(searchStatus)
            }else {
                if !didSearchVideo {
                    getPlaylistData()
                }else {
                    getSearchData(didSearchVideo)
                }
            }
            
        case (1, false):
            
            getPlaylistData()
        default :
            
            print("There's unexpected situation")
            break
        }
        activityView.hidden = true
    }
    
    func getChannelData() {
        var url = ""
        if !self.searchStatus {
            
            url = "https://www.googleapis.com/youtube/v3/channels?part=snippet%2CcontentDetails&forUsername=\(channels[channelIndex])&key=\(apiKey)"
            
        }else {
            
            let channelName = channels[channelIndex]
            if let channelId = channelNameWithid[channelName]?["channelId"] {
                
            url = "https://www.googleapis.com/youtube/v3/channels?part=snippet%2CcontentDetails&id=\(channelId)&key=\(apiKey)"
                
            }
        }
        
        Alamofire.request(.GET, url).validate().responseJSON(queue: dispatch_get_main_queue(), options: NSJSONReadingOptions.MutableContainers) { response in
            if response.result.isSuccess {
                if let value = response.result.value {
                    let json = JSON(value)
                    if let playlistId = json["items"][0]["contentDetails"]["relatedPlaylists"]["uploads"].string {
                        
                        if let description = json["items"][0]["snippet"]["description"].string {
                            
                            if let imageURL = json["items"][0]["snippet"]["thumbnails"]["high"]["url"].string {
                                
                                if let channelId = json["items"][0]["id"].string {
                                    if !self.searchStatus {
                                        
                                        self.channelNameWithid["\(self.channels[self.channelIndex])"] = ["playlistId": playlistId,"description":description,"imageURL":imageURL,"channelId":channelId]

                                    }else {
                                        if self.channelNameWithid["\(self.channels[self.channelIndex])"]!["playlistId"] == "" {
                                            self.channelNameWithid["\(self.channels[self.channelIndex])"]!["playlistId"] = playlistId
                                        }
                                    }
                                    self.channelIndex += 1
                                    if self.channelIndex < self.channels.count {
                                        self.getChannelData()
                                    
                                    }else {
                                        self.channelIndex = 0
                                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                                    }
                                }
                            }
                        }
                    }
                }
            }else{
                print("channel fetch error : \(response.result.error?.localizedDescription)")
            }
        }
    }
    
    func getPlaylistData() {
        
        let name = channels[didTapAtIndex ?? 0] ?? "Apple"
        
        if let playlistId = channelNameWithid[name] {
            
            let queryId = playlistId["playlistId"]
            
            let url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails%2Cstatus&playlistId=\(queryId!)&key=\(apiKey)"

            Alamofire.request(.GET, url).validate().responseJSON(queue: dispatch_get_main_queue(), options: NSJSONReadingOptions.MutableContainers, completionHandler: { response in
                if response.result.isSuccess {
                    
                    guard let value = response.result.value else {
                        return
                    }
                    
                    let json = JSON(value)
                    let itemCount = json["items"].arrayValue.count
                    let results = json["pageInfo"]["totalResults"].intValue
                    
                    if results == 0 {
                        let alert = UIAlertController(title: "No playlist", message: "Try another channel", preferredStyle: .Alert)
                        let alertAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
                        alert.addAction(alertAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.segControlView.selectedSegmentIndex = 0
                        return
                    }
                    
                    self.playlist.removeAll()
                    
                    for indexValue in 0..<itemCount {
                        let videoId = json["items",indexValue,"snippet"]["resourceId"]["videoId"].stringValue
                        guard let title = json["items",indexValue,"snippet","title"].string else {
                            return
                        }
                        guard let thumbnailUrl = json["items",indexValue,"snippet","thumbnails","medium","url"].string else {
                            return
                        }
                        self.playlistWithAttribute[name] = ["videoId":videoId,"videoTitle":title,"videoImg": thumbnailUrl]
                        let dic = ["videoId":videoId,"videoTitle":title,"videoImg": thumbnailUrl]
                        self.playlist.insert(dic, atIndex: 0)
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                }else{
                    print("videos fetch error : \(response.result.error)")
                }
            })
        }
    }
    
    func getSearchData(status: Bool) {
        if status {
            
            if let query = searchTextFiled.text {
                
                let encodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
                var url = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(encodedQuery!)&type=channel&key=\(apiKey)"
                
                if segControlView.selectedSegmentIndex == 1 {
                    
                    url = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(encodedQuery!)&type=video&key=\(apiKey)"
                }
                
                Alamofire.request(.GET, url).validate().responseJSON(queue: dispatch_get_main_queue(), options: NSJSONReadingOptions.MutableContainers, completionHandler: { response in
                    if response.result.isSuccess {
                        guard let value = response.result.value else{
                            return
                        }
                        
                        let json = JSON(value)
                        
                        guard let items = json["items"].array else{
                            return
                        }
                        if self.segControlView.selectedSegmentIndex == 0 {
                            self.channels.removeAll()
                            for item in items {
                                guard let desc = item["snippet"]["description"].string else{
                                    return
                                }
                                guard let channelId = item["snippet"]["channelId"].string else {
                                    return
                                }
                                guard let thumbnailUrl = item["snippet"]["thumbnails"]["high"]["url"].string else {
                                    return
                                }
                                guard let channelName = item["snippet"]["title"].string else {
                                    return
                                }

                                self.channels.append(channelName)
                                self.channelNameWithid[channelName] = ["channelId":channelId,"description":desc,"imageURL":thumbnailUrl,"playlistId":""]
                                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                                
                            }
                            if self.channels.count > 0 {
                                self.getChannelData()
                            }
                        }else {
                            
                            self.playlist.removeAll()
                            
                            for item in items {
                                guard let videoId = item["id"]["videoId"].string else {
                                    return
                                }
                                guard let videoTitle = item["snippet"]["title"].string else {
                                    return
                                }
                                guard let videoImg = item["snippet"]["thumbnails"]["high"]["url"].string else {
                                    return
                                }
                                guard let name = item["snippet"]["channelTitle"].string else {
                                    return
                                }

                                self.playlistWithAttribute[name] = ["videoId":videoId,"videoTitle":videoTitle,"videoImg": videoImg]
                                let dic = ["videoId":videoId,"videoTitle":videoTitle,"videoImg": videoImg]
                                self.playlist.insert(dic, atIndex: 0)
                                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                                self.didSearchVideo = true
                            }
                        }
                    }
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Video" {
            if let dv = segue.destinationViewController as? PlayerViewController {
                
                let indexPath = tableView.indexPathForSelectedRow
                let name = playlist[indexPath!.row]
                
                if let videoId = name["videoId"] {
                    dv.videoId = videoId
                    dv.title = name["videoTitle"]
                }
            }
        }
    }
    
    // - MARK : TableViewDelegate implement
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activityView.hidden = false
        if segControlView.selectedSegmentIndex == 0 {
            
            didTapAtIndex = indexPath.row
            self.segControlView.selectedSegmentIndex = 1
            searchTextFiled.text = channels[indexPath.row]
            lastSearchVideoName = searchTextFiled.text!
            didSearchVideo = false
            getPlaylistData()
            
        }else if segControlView.selectedSegmentIndex == 1 {
            
            performSegueWithIdentifier("Show Video", sender: self)
        }
        activityView.hidden = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segControlView.selectedSegmentIndex == 0 {
            return 140
        }else{
            return 110
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segControlView.selectedSegmentIndex == 0 {
            return channels.count
        }else {
           return playlist.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segControlView.selectedSegmentIndex == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell", forIndexPath: indexPath)
            let imageView = cell.viewWithTag(11) as! UIImageView
            let name = cell.viewWithTag(12) as! UILabel
            let des = cell.viewWithTag(13) as! UILabel
            let info = channels[indexPath.row]
            let attribute = channelNameWithid[info]
            
            name.text = info
            
            if let description = attribute?["description"] {
                des.text = description
            }
            
            if let imageURL = attribute?["imageURL"] {
                let url = NSURL(string: imageURL)
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                dispatch_async(dispatch_get_global_queue(qos, 0), { 
                    let imageData = NSData(contentsOfURL: url!)
                    if let data = imageData {
                        dispatch_async(dispatch_get_main_queue(), {
                            if url?.URLString == imageURL {
                                imageView.image = UIImage(data: data)
                            }
                        })
                    }
                })
            }
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VideosCell", forIndexPath: indexPath)
            let imageView = cell.viewWithTag(14) as! UIImageView
            let videoTitle = cell.viewWithTag(15) as! UILabel
            let info = playlist[indexPath.row]
            
            videoTitle.text = info["videoTitle"]
            
            if let imageURL = info["videoImg"] {
                let url = NSURL(string: imageURL)
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                dispatch_async(dispatch_get_global_queue(qos, 0), {
                    let imageData = NSData(contentsOfURL: url!)
                    if let data = imageData {
                        dispatch_async(dispatch_get_main_queue(), {
                            if url?.URLString == imageURL {
                                imageView.image = UIImage(data: data)
                            }
                        })
                    }
                })
            }
            
            return cell
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // - MARK: For Search feature
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if searchTextFiled.becomeFirstResponder() {
            
            textField.resignFirstResponder()
            if let text = textField.text {
                
                if text.characters.count == 0 {
                    return true
                }
                
                searchStatus = true
                getData()
                
                if segControlView.selectedSegmentIndex == 0 {
                    lastSearchChannelName = textField.text
                    didTapAtIndex = nil
                }else {
                    lastSearchVideoName = textField.text!
                }
            }
        }
        return true
    }
}

