//
//  ViewController.swift
//  WikiFace
//
//  Created by 賢瑭 何 on 2016/5/30.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var faceView: UIImageView!
    
    var image: UIImage? {
        get {
            return faceView?.image
        }
        set{
            faceView?.image = newValue
        }
    }
    
    var request: WikiFaceRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        faceView.alpha = 0.0
        faceView.transform = CGAffineTransformMakeScale(0.2, 0.2)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text {
            processData(text)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func processData(name: String) {
        request = nil
        request = WikiFaceRequest(fullName: name)
        if let dataRequest = request {
            dataRequest.fetchData({ data in
                dispatch_async(dispatch_get_main_queue(), {
                    if name == self.searchField.text {
                        if let imageData = data {
                            self.image = UIImage(data: imageData)
                        }
                    }
                    if self.image != nil {
                        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                                self.faceView.alpha = 1
                                self.faceView?.transform = CGAffineTransformIdentity
                        }, completion: nil)
                    }
                })
            })
        }
    }
}

