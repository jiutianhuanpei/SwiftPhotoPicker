//
//  SHBPickerController.swift
//  SwiftPhotoPicker
//
//  Created by shenhongbang on 16/4/15.
//  Copyright © 2016年 shenhongbang. All rights reserved.
//

import UIKit
import Photos

typealias SelectedImages = (allImages : [UIImage]) -> Void

class SHBPickerController: UINavigationController {
    
    var selectedImages: SelectedImages?

    
    class func pickerController() -> SHBPickerController {
        
        let results = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)

        let photoPicker = SHBPhotoController.init(result: results)
        
        let album = SHBAlbumListController()
        
        let picker = SHBPickerController.init(rootViewController: album)
        
        photoPicker.selectedImages = { (allImages) in
            picker.selectedImages!(allImages: allImages)
        }
        
        
        var controllers = picker.viewControllers;
        controllers.append(photoPicker)
        
        picker.viewControllers = controllers
        
        return picker
    }
    
    
}

class PhotoItem: UICollectionViewCell {
    
    private var imgView :UIImageView!
    private var btn : UIButton!
    private var tap : UITapGestureRecognizer!
    
    private var asset: PHAsset!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.redColor()
        imgView = UIImageView.init(frame: self.bounds)
        imgView.contentMode = .ScaleToFill
        imgView.userInteractionEnabled = true
        self.addSubview(imgView)
        
        tap = UITapGestureRecognizer.init(target: self, action: #selector(clickedBtn))
        imgView.addGestureRecognizer(tap)
        
        btn = UIButton.init(type: .Custom)
        btn.frame = CGRectMake(CGRectGetWidth(frame) - 15, 5, 10, 10)
        btn.setImage(UIImage.init(named: "icon_gouxuan_nm"), forState: .Normal)
        btn.setImage(UIImage.init(named: "icon_gouxuan_pre"), forState: .Selected)
        btn.addTarget(self, action: #selector(clickedBtn), forControlEvents: .TouchUpInside)
        self.addSubview(btn)
        
    }
    
     func configImage(image : UIImage) {
        imgView.image = image
    }
    
    private func configAsset(temp : PHAsset) {
        asset = temp
        let manager = PHCachingImageManager.init()
        manager.requestImageForAsset(asset, targetSize: self.bounds.size, contentMode: .AspectFill, options: nil) { (image, obj) in
            if image != nil {
                self.imgView.image = image!
            }
        }
    }
    
    @objc private func clickedBtn(btn: AnyObject) {
        
        self.shbSendAction("clickedPhoto:", sender: self)
        self.btn.selected = !self.btn.selected
        
    }
    
    override var selected: Bool {
        get{
            return self.btn.selected
        }
        set{
            self.btn.selected = selected
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SHBPhotoController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var photoView : UICollectionView!
    private var dataArray : NSMutableArray!
    
    private var manager : PHCachingImageManager!
    private var results: PHFetchResult?
    
    
    var selectedImages: SelectedImages?
    
    
    //MARK: - life circle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    
    
    
    init(result: PHFetchResult) {
        super.init(nibName: nil, bundle: nil)
        results = result
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellowColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "取消", style: .Plain, target: self, action: #selector(disMiss))
        
        dataArray = NSMutableArray.init(capacity: 0)
        manager = PHCachingImageManager()
        
        let layout = UICollectionViewFlowLayout.init()
        
        let kWidth = CGRectGetWidth(UIScreen.mainScreen().bounds)
        let space : CGFloat = 1.0
        
        let itemW = (kWidth - 3 * space) / 4.0
        layout.itemSize = CGSizeMake(itemW, itemW)
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        
        photoView = UICollectionView.init(frame: view.bounds, collectionViewLayout: layout)
        photoView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        photoView.delegate = self
        photoView.dataSource = self
        photoView.allowsMultipleSelection = true
        view.addSubview(photoView)
        
        photoView.registerClass(PhotoItem.self, forCellWithReuseIdentifier: String(PhotoItem.self))
        
        
        self.setToolbarItems([UIBarButtonItem.init(title: "Preview", style: .Plain, target: self, action: #selector(preview)), UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil), UIBarButtonItem.init(title: "Sure", style: .Plain, target: self, action: #selector(makeSure))], animated: false)
        
        PHPhotoLibrary.requestAuthorization { (PHAuthorizationStatus) in
            if PHAuthorizationStatus == .Authorized {
            }
        }
    }

    
    
    //MARK:- toolbar
    @objc private func makeSure() {
        
        self.getImages { (images: [UIImage]) in
            self.dismissViewControllerAnimated(true, completion: {
                if self.selectedImages != nil {
                    self.selectedImages!(allImages: images)
                }
            })
            
        }
    }
    
    @objc private func preview() {
        self.getImages { (images) in

            let browser = SHBPhotoBrowser.init(images: images, index: 0)
//            self.navigationController?.pushViewController(browser, animated: true)
        self.presentViewController(browser, animated: true, completion: nil)
        }

    }
    

    private func getImages(complete: ([UIImage]) -> Void) {
        let indexPaths: NSArray = self.photoView.indexPathsForSelectedItems()!
        
        var images: [UIImage] = []
        
        for index in indexPaths {
            
            let item = self.photoView.cellForItemAtIndexPath(index as! NSIndexPath) as! PhotoItem
            
            manager.requestImageForAsset(item.asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil, resultHandler: { (image : UIImage?, obj) in
                
                images.append(image!)
                if images.count == indexPaths.count {
                    complete(images)
                }
            })
        }
    }


    
    private func getData() {
        results = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
        dispatch_async(dispatch_get_main_queue()) { 
            self.photoView.reloadData()
        }
    }
    
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item: PhotoItem = collectionView.dequeueReusableCellWithReuseIdentifier(String(PhotoItem.self), forIndexPath: indexPath) as! PhotoItem
        
        let asset = self.results![indexPath.row] as! PHAsset
        item.configAsset(asset)
        return item
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return results!.count
    }
    
    @objc private func disMiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    //MARK: - 引出
    func clickedPhoto(sender: AnyObject) {
        let item = sender as! PhotoItem
        
        let indexPath = self.photoView.indexPathForCell(item)
        
        if item.selected {
         self.photoView.deselectItemAtIndexPath(indexPath!, animated: true)
        } else {
        self.photoView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
    }
    
    
    
}

extension UIView {
    func shbSendAction(actionName : String, sender: AnyObject) -> Bool {
        
        var target : UIResponder? = sender as? UIResponder
        
        let action : Selector = Selector(actionName)
        
        while target != nil && !target!.canPerformAction(action, withSender: sender) {
            
            target = target!.nextResponder()
        }
        
        return target == nil ? false : UIApplication.sharedApplication().sendAction(action, to: target, from: sender, forEvent: nil)
    }
}
