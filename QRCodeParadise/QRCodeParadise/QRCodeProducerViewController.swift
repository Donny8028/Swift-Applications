//
//  QRCodeProducerViewController.swift
//  QRCodeParadise
//
//  Created by 賢瑭 何 on 2016/6/12.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit

class QRCodeProducerViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var middleTitle: UINavigationItem!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var urlTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.delegate = self
        urlTextField.delegate = self
        let customTitle = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 100, height: 30))
        customTitle.textAlignment = .Center
        customTitle.font = UIFont.systemFontOfSize(20)
        customTitle.text = "Make QRCode"
        customTitle.textColor = UIColor.whiteColor()
        middleTitle.titleView = customTitle
    }
    
    func createQRCode(text: String) {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        if text.canBeConvertedToEncoding(5) {
            
            let data = (text as NSString).dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            let cimg = filter?.outputImage
            let scaleX = qrImageView.frame.width / cimg!.extent.size.width
            let scaleY = qrImageView.frame.height / cimg!.extent.size.height
            let transformImg = cimg!.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
            
            let img = UIImage(CIImage: transformImg)
            qrImageView.image = img
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlTextField.resignFirstResponder()
        if let text = textField.text {
            createQRCode(text)
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return UIPercentDrivenInteractiveTransition()
    }
}
