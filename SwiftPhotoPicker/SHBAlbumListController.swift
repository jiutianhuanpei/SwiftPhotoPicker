//
//  SHBAlbumListController.swift
//  SwiftPhotoPicker
//
//  Created by shenhongbang on 16/4/15.
//  Copyright © 2016年 shenhongbang. All rights reserved.
//

import UIKit
import Photos

class SHBAlbumListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @objc private func disMiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: { 
            
        })
    }
    
    var tableView: UITableView!
    var manager: PHCachingImageManager!
    var result: PHFetchResult?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellowColor()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "返回", style: .Plain, target: self, action: #selector(disMiss))
        
        tableView = UITableView.init(frame: self.view.bounds, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        
        
        manager = PHCachingImageManager.init()
        
        result = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil)
        
    }
    
    
    //MARK:-  UITableViewDelegate, UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell.self), forIndexPath: indexPath)
        let collection = result![indexPath.row] as! PHAssetCollection
        
        let inResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
        
        let title = "\(collection.localizedTitle!) (\(inResult.count))"
        
        cell.textLabel?.text = title
        
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result == nil ? 0 : result!.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let collection  = self.result![indexPath.row] as! PHAssetCollection
        
        let result = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
        
        if result.count <= 0 {
            return
        }
        
        let photoPicker = SHBPhotoController.init(result: result)
        self.navigationController?.pushViewController(photoPicker, animated: true)
    
    }
}





class BrowserPhotoItem: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrolView: UIScrollView!
    var backView: UIView!
    var imgView: UIImageView!
    
    func config(image: UIImage) {
        imgView.image = image
        scrolView.zoomScale = 1
//        let width = CGRectGetWidth(self.frame);
//        
//        var h = image.size.height * width / image.size.width;
//        
//        if image.size.height / image.size.width > self.frame.height / width {
//            //竖图
//            backView.frame = CGRectMake(2, 0, width, h)
//            
//        } else {
//            if h < 1 || isnan(Double(h)) {
//               h = CGRectGetHeight(self.frame)
//            }
//            
//            backView.frame = CGRectMake(2, 0, width, h)
//            backView.center = self.center
//        }
//        
//        if backView.frame.height > self.frame.height && backView.frame.height - self.frame.height <= 1 {
//            backView.bounds = CGRectMake(0, 0, width, CGRectGetHeight(self.frame))
//        }
//        
//        scrolView.contentSize = CGSizeMake(self.frame.width, max(backView.frame.height, self.frame.height))
//        scrolView.scrollRectToVisible(self.bounds, animated: false)
//        imgView.frame = backView.bounds
//        imgView.backgroundColor = UIColor.yellowColor()
//        scrolView.backgroundColor = UIColor.redColor()
    }
    
    private func toBounds(frame: CGRect) -> CGRect {
        
        let bounds = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
        return bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bounds = toBounds(frame)
        
        scrolView = UIScrollView.init(frame: bounds)
        scrolView.contentSize = CGSizeMake(bounds.width - 1, bounds.height - 1)
        scrolView.delegate = self
        scrolView.minimumZoomScale = 1
        scrolView.maximumZoomScale = 4
        self.addSubview(scrolView)
        
        
        backView = UIView.init(frame: CGRectMake(2, 0, CGRectGetWidth(frame) - 4, CGRectGetHeight(frame)))
        backView.clipsToBounds = true
        scrolView.addSubview(backView)
        
        imgView = UIImageView.init(frame: backView.bounds)
        imgView.contentMode = .ScaleAspectFit
        imgView.userInteractionEnabled = true
        backView.addSubview(imgView)
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return backView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 :  0;
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0;
    
        
        backView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY)
        
    }
    
    
}


class SHBPhotoBrowser: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var browser : UICollectionView!
    
    var shbResult: [UIImage]?
    var shbIndex: Int = 0
    
    
    
    init(images: [UIImage], index: Int) {
        super.init(nibName: nil, bundle: nil)
        
        shbResult = images
        shbIndex = index
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        browser = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        browser.delegate = self
        browser.dataSource = self
        browser.backgroundColor = UIColor.whiteColor()
        browser.pagingEnabled = true
        self.view.addSubview(browser)
        
        browser.registerClass(BrowserPhotoItem.self , forCellWithReuseIdentifier: String(BrowserPhotoItem.self))
        
        let swipe = UISwipeGestureRecognizer.init(target: self, action: #selector(dismissFromPhotoBrowser))
        swipe.direction = .Down
        browser.addGestureRecognizer(swipe)
        
    }
    
    
    //MARK:- UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCellWithReuseIdentifier(String(BrowserPhotoItem.self), forIndexPath: indexPath) as! BrowserPhotoItem
        
        
        item.config(shbResult![indexPath.row])
        
        return item
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shbResult == nil ? 0 : shbResult!.count
    }
    
    
    func dismissFromPhotoBrowser()  {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}





