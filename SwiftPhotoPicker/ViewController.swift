//
//  ViewController.swift
//  SwiftPhotoPicker
//
//  Created by shenhongbang on 16/4/15.
//  Copyright © 2016年 shenhongbang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func chooseImage(sender: AnyObject) {
        
        let photoPicker = SHBPickerController.pickerController()
        photoPicker.selectedImages = { (allImages: [UIImage]) in
            
            print("____++++\(allImages)")
        }
        
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

