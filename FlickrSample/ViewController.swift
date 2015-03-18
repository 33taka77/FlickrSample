//
//  ViewController.swift
//  FlickrSample
//
//  Created by 相澤 隆志 on 2015/03/17.
//  Copyright (c) 2015年 相澤 隆志. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var dearchText:String = ""
    var images:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBar.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBarSearchButtonClicked(searchBarText:UISearchBar!) {
        searchBarText.resignFirstResponder()
        dearchText = searchBarText.text
        self.fetchImages()
    }
    
    func fetchImages() {
        let manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        let url :String = "https://api.flickr.com/services/rest/"
        let parameters :Dictionary = [
            "method"         : "flickr.interestingness.getList",
            "api_key"        : "86997f23273f5a518b027e2c8c019b0f",
            "per_page"       : "99",
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_t,url_z",
        ]
        let requestSuccess = {
            (operation:AFHTTPRequestOperation!, responseObject:AnyObject?) -> Void in
            let dict:NSDictionary = responseObject as NSDictionary
            let key: NSString = NSString(string: "photos")
            let imgs:NSDictionary? = dict.objectForKey(key) as? NSDictionary
            let subKey:NSString = NSString(string: "photo")
            let array:[NSDictionary] = imgs!.objectForKey(subKey) as [NSDictionary]
            self.images = array //imgs!.objectForKey(subKey) as [Dictionary]
            self.collectionView.reloadData()
        }
        
        let requestFailure = {
            (operation :AFHTTPRequestOperation!, error :NSError!) -> Void in
            NSLog("requestFailure: \(error)")
        }

        manager.GET(url, parameters: parameters, success: requestSuccess, failure: requestFailure)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell :ThumbnailCollectionViewCell! = self.collectionView.dequeueReusableCellWithReuseIdentifier("ThumbnailCell",forIndexPath: indexPath) as ThumbnailCollectionViewCell
        
        let item = self.images[indexPath.row] as NSDictionary
        let photoUrlString:String = item["url_t"] as String
        let url : NSURL = NSURL(string: photoUrlString)!
        let request : NSURLRequest = NSURLRequest(URL: NSURL(string: photoUrlString)!)
        let imageRequestSuccess = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
            cell.thumbnailImage.image = image;
            cell.thumbnailImage.alpha = 0
            UIView.animateWithDuration(0.2, animations: {
                cell.thumbnailImage.alpha = 1.0
            })
        }
        let imageRequestFailure = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, error : NSError!) -> Void in
            NSLog("imageRequrestFailure")
        }
        cell.thumbnailImage.setImageWithURLRequest(request, placeholderImage: nil, success: imageRequestSuccess, failure: imageRequestFailure)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.images.count
        return count
    }
    
    
}

