//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by 賢瑭 何 on 2016/6/9.
//  Copyright © 2016年 Donny. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices
import WebKit

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, SFSafariViewControllerDelegate,WKNavigationDelegate {

    @IBOutlet weak var scanerView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
    
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var device: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var barCodeBounds: UIView?
    var url: NSURL?
    var navVC: UINavigationController?
    var rvc: UIViewController?
    let progressView = UIProgressView(progressViewStyle: .Default)
    let webView = WKWebView()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapForSafari(_:)))
        urlLabel.addGestureRecognizer(tap)
        urlLabel.layer.cornerRadius = 5.0
        urlLabel.alpha = 0.0
        
        
        barCodeBounds = UIView()
        barCodeBounds?.layer.borderColor = UIColor.greenColor().CGColor
        barCodeBounds?.layer.borderWidth = 2.0
        scanerView.addSubview(barCodeBounds!)
        
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        session = AVCaptureSession()
        do {
        input = try AVCaptureDeviceInput(device: device)
        }
        catch let error as NSError{
            print("\(error.localizedDescription)")
        }
        output = AVCaptureMetadataOutput()
        guard let _ = session?.canAddInput(input) else{
            print("Can't add input")
            return
        }
        guard let _ = session?.canAddOutput(output) else{
            print("Can't add output")
            return
        }
        session?.addInput(input)
        session?.addOutput(output)
        
        output?.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        output?.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        // Configure properties after being added to sesstion.
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = view.layer.bounds
        scanerView.layer.addSublayer(previewLayer!)
        
        scanerView.bringSubviewToFront(barCodeBounds!)
        scanerView.bringSubviewToFront(urlLabel)
        session?.startRunning()
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.isEmpty {
            barCodeBounds?.frame = CGRectZero
            urlLabel.text = nil
        }
        
        if let detectObjects = metadataObjects {
            if let detectObject = detectObjects.last {
                if detectObject.type == AVMetadataObjectTypeQRCode {
                    if let readableObject = detectObject as? AVMetadataMachineReadableCodeObject {
                        let barCodeObject = previewLayer?.transformedMetadataObjectForMetadataObject(readableObject)
                        barCodeBounds?.frame = barCodeObject!.bounds
                        if let stringURL = readableObject.stringValue {
                            if urlLabel.text == nil {
                                urlLabel.text = stringURL
                                configureInteractionOfTap(stringURL)
                                showURL()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        session?.stopRunning()
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.translucent = true
        super.viewWillAppear(animated)
        if !session!.running {
            session?.startRunning()
        }
    }
    
    
    func showURL() {
        if urlLabel.text != nil {
            UIView.animateWithDuration(0.8, delay: 0.0, options: .CurveEaseOut, animations: {
                self.urlLabel.alpha = 1
                }, completion: nil)
        }
    }
    
    func dismissNav() {
        self.urlLabel.alpha = 0.0
        self.barCodeBounds?.frame = CGRectZero
        navVC?.dismissViewControllerAnimated(true, completion: {
            self.urlLabel.text = nil
            self.url = nil
            self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        })
    }
    
    
    //- MARK: For Web Configure
    
    func configureInteractionOfTap(address:String?) {
        guard let processedUrl = address else {
            print("Invaild web address")
            return
        }
        if processedUrl == urlLabel.text {
            // Be aware of the url must prefix "http://"
            if processedUrl.hasPrefix("http://") {
                url = NSURL(string: processedUrl)
            }else if processedUrl.hasPrefix("www") {
                let appendURL = "http://" + processedUrl
                url = NSURL(string: appendURL)
            }else {
                print("This URL maybe Invalid")
                url = NSURL(string: processedUrl)
            }
        }
    }
    
    func tapForSafari(gesture: UITapGestureRecognizer) {
        
        if let scannedURL = url {
            if #available(iOS 9.0, *) {
                
                let safari = SFSafariViewController(URL: scannedURL, entersReaderIfAvailable: true)
                safari.delegate = self
                presentViewController(safari, animated: true, completion: nil)
                
            }else {
                
                let request = NSURLRequest(URL: scannedURL)
                webView.loadRequest(request)
                webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
                presentViewController(navVC!, animated: true, completion: nil)
            }
        }
    }
    
    func configureWebView() {
        
        let barItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.dismissNav))
        rvc = UIViewController()
        rvc!.navigationItem.rightBarButtonItem = barItem
        rvc?.title = webView.title
        
        webView.frame = rvc!.view.frame
        webView.navigationDelegate = self
        
        rvc!.view.addSubview(progressView)
        rvc!.view.bringSubviewToFront(progressView)
        rvc!.view.insertSubview(webView, belowSubview: progressView)
        
        navVC = UINavigationController(rootViewController: rvc!)
        navVC!.hidesBarsOnSwipe = true
        
        let height = navVC!.navigationBar.frame.height
        progressView.frame = rvc!.view.frame
        progressView.transform = CGAffineTransformMakeTranslation(0.0, height + 20)
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            if let estimateProgress = change?[NSKeyValueChangeNewKey] as? Double {
                progressView.setProgress(Float(estimateProgress), animated: true)
                progressView.hidden = Float(estimateProgress) == 1
            }
        }
    }
    
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Reach Fails!", message: "Please check your web address", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { _ in
            self.dismissNav()
        }
        alert.addAction(action)
        navVC!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print("can't frame the view!")
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

