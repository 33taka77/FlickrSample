//
//  ViewController.swift
//  FlickrSample
//
//  Created by 相澤 隆志 on 2015/03/17.
//  Copyright (c) 2015年 相澤 隆志. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var searchText:String = ""
    var images:[NSDictionary] = []
    var prevSpace_x:CGFloat = 0
    var prevSpace_y:CGFloat = 0
    var currentTotalWidth:CGFloat = 0
    
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
        self.searchText = searchBarText.text
        self.fetchImages()
    }
    
    func fetchImages() {
        let manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        let url :String = "https://api.flickr.com/services/rest/"
        var parameters :Dictionary = [
            //"method"         : "flickr.interestingness.getList",
            "method"         : "flickr.photos.search",
            "api_key"        : "685147fe878a39bf9b9853ae77b31e0b",
            "per_page"       : "99",
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_m,url_z",
        ]
        parameters["text"] = self.dearchText
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
        
        //cell.thumbnailImage.image = self.getImageDataInCell( cell, index:indexPath.row )!
        
        
        let item = self.images[indexPath.row] as NSDictionary
        let photoUrlString:String = item["url_m"] as String
        let url : NSURL = NSURL(string: photoUrlString)!
        let request : NSURLRequest = NSURLRequest(URL: NSURL(string: photoUrlString)!)
        let imageRequestSuccess = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
            let size: CGSize = image.size
            let x:CGFloat = size.width
            let y:CGFloat = size.height
            
            print("Real size: width = \(x)")
            println("Real size: height = \(y)")
            

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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()

        let item = self.images[indexPath.row] as NSDictionary
        let photoUrlString:String = item["url_m"] as String
//        let url : NSURL = NSURL(string: photoUrlString)!
        var imageData:UIImage? = nil
        
        let request:NSURLRequest! = NSURLRequest(URL: NSURL(string: photoUrlString)!)
        let requestOpe:AFHTTPRequestOperation = AFHTTPRequestOperation(request: request)
        
        requestOpe.responseSerializer = AFImageResponseSerializer()
        
        
        let requestSuccess = {
            (operation:AFHTTPRequestOperation!, responseObject:AnyObject?) -> Void in
            if let obj = responseObject as? NSData {
                imageData = UIImage(data: obj)
            }
        }
        
        let requestFailure = {
            (operation :AFHTTPRequestOperation!, error :NSError!) -> Void in
            NSLog("requestFailure: \(error)")
        }

        requestOpe.setCompletionBlockWithSuccess(requestSuccess, failure: requestFailure)
        requestOpe.start()
        
        
        //let operation:AFImageRequestOperation = AFImageRequestOperation(request, imageProcessingBlock:nil, success:requestSuccess, failure:requestFailure)
        
        
        //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photourl]];
        //AFImageRequestOperation *operation;
        //operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
        //    imageProcessingBlock:nil
        //    cacheName:nil
        //    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
        //    }
        //    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //    NSLog(@"%@", [error localizedDescription]);
        //    }];
        
        
        
        
        /*
        let serializer:AFImageResponseSerializer = AFImageResponseSerializer()
        manager.responseSerializer = serializer
         manager.GET(photoUrlString, parameters: nil, success: requestSuccess, failure: requestFailure)
        */
        
        let img_widthStr = item["width_m"] as NSString
        let img_heightStr = item["height_m"] as NSString
        
        println("width = "+img_widthStr + " : hight = "+img_heightStr)
        
        let img_width:CGFloat = CGFloat(img_widthStr.floatValue)
        let img_height:CGFloat = CGFloat(img_heightStr.floatValue)

        var x:CGFloat = 50
        var y:CGFloat = 50
        if img_width > img_height {
            x = img_width > self.view.frame.size.width ? self.view.frame.size.width:img_width
            y = img_height
            if x > prevSpace_x {
                x = prevSpace_x
                y = prevSpace_x/img_width*img_height
            }
        }else{
            x = 150.0
            y = x/img_width*img_height
        }
        currentTotalWidth += x
        if currentTotalWidth >= self.view.frame.size.width {
            currentTotalWidth = 0
        }
        prevSpace_x = self.view.frame.size.width - currentTotalWidth
        
        //x = 320
        //y = 160
        x=img_width
        y=img_height
        return CGSizeMake(x, y)
    }

    func getImageDataInCell(cell:ThumbnailCollectionViewCell!, index: Int)->UIImage? {
        var imageData :UIImage? = nil
        let item = self.images[index] as NSDictionary
        let photoUrlString:String = item["url_m"] as String
        let url : NSURL = NSURL(string: photoUrlString)!
        let request : NSURLRequest = NSURLRequest(URL: NSURL(string: photoUrlString)!)
        let imageRequestSuccess = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
            imageData! = image;
        }
        let imageRequestFailure = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, error : NSError!) -> Void in
            NSLog("imageRequrestFailure")
        }
        cell.thumbnailImage.setImageWithURLRequest(request, placeholderImage: nil, success: imageRequestSuccess, failure: imageRequestFailure)

        return imageData
    }
    
}

