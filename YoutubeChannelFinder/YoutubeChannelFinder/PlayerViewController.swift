//
//  PlayerViewController.swift
//  YoutubeChannelFinder
//
//  Created by 賢瑭 何 on 2016/6/14.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class PlayerViewController: UIViewController {

    @IBOutlet weak var playView: YTPlayerView!
    
    var videoId: String?
    var videotitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = videoId {
            playView.loadWithVideoId(id)
        }
        if let title = videotitle {
            self.title = title
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
