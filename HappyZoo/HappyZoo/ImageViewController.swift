//
//  ImageViewController.swift
//  HappyZoo
//
//  Created by 賢瑭 何 on 2016/6/13.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var animalImage: UIImageView!
    @IBOutlet weak var textViewWithDescription: UITextView!
    
    var animal: Animal? {
        didSet{
            if view.window != nil {
                getImage()
            }
        }
    }
    
    var image: UIImage? {
        get {
            return animalImage.image
        }
        set {
            animalImage?.image = newValue
        }
    }
    
    func getImage() {
        if let goodAnimal = animal {
            if let imageURL = NSURL(string: goodAnimal.picImageURL) {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                let data = NSData(contentsOfURL: imageURL)
                    dispatch_async(dispatch_get_main_queue(), {
                        if imageURL.URLString == goodAnimal.picImageURL {
                            if let imagedata = data {
                                self.image = UIImage(data: imagedata)
                            }
                        }
                    })
                }
            }
            if animal?.detail.characters.count > 0 {
                textViewWithDescription?.text = animal?.detail ?? "暫無簡介"
            }else {
                textViewWithDescription?.text = "暫無簡介"
            }
            self.title = animal?.destription
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.image == nil {
            getImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
