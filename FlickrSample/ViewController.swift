//
//  ViewController.swift
//  FlickrSample
//
//  Created by 相澤 隆志 on 2015/03/17.
//  Copyright (c) 2015年 相澤 隆志. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var dearchText:String = ""
    var images:[Dictionary<String,String>] = []
    
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
            "extras"         : "",
        ]
        let requestSuccess = {
            (operation:AFHTTPRequestOperation!, responseObject:AnyObject?) -> Void in
            let dict:NSDictionary = responseObject as NSDictionary
            let key: NSString = NSString(string: "photo")
            let imgs:NSDictionary = dict.objectForKey(key) as NSDictionary
            let subKey:NSString = NSString(string: "photos")
            self.images = imgs.objectForKey(subKey) as [Dictionary]
        }

    }
}

