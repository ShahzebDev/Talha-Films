//
//  HomeCollectionViewController.swift
//  Talha Films
//
//  Created by Moazzam Tahir on 24/05/2019.
//  Copyright © 2019 Moazzam Tahir. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SkeletonView

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let refreshControl = UIRefreshControl()
    let activityIndicator = UIActivityIndicatorView()
    
    var shouldAnimate = true //to animate the cell
    var fetchingMore = false
    
    //array of video thumbnail cells in view.
    var videos: [ThumbnailDetails]?
    
    //to copy selected cell object to this variable
    var selectedCell: ThumbnailDetails?
    
    var channelIdArray = ["UCNZ-ZdWIRFM88Fxvlpug73A","UC3__mxJ0T3dXisOp3OP49DA","UCt5pwA1JdEMaQ7XX_FldPzA","UC75zRBEe-jA6jFGDliL_-NQ","UC5ZAU-hc5NOeuXUcb4gyqcQ"]
    
    private let apiKey = "AIzaSyB9lzfb9eiZJCYC8raCo6Omj91gn-mZsN0"
    let youtubeApiCall = "https://www.googleapis.com/youtube/v3/activities?"
    let videoApiCall = "https://www.googleapis.com/youtube/v3/videos?"
    let channelApiCall = ""
    //let channelId = "UCNZ-ZdWIRFM88Fxvlpug73A"

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true //to display large title
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        //registered cell with CellUIDetails to show the views
        collectionView.register(DetailedCell.self, forCellWithReuseIdentifier: "cell")
        
        //method to refreshing upon pulling down the view.
        pullToRefresh()
    
        fetchVideos()
    }
    
    func pullToRefresh() {
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshControl.addTarget(self, action: #selector(refreshTheFeed(_:)), for: .valueChanged)
        print("method called")
    }
    
    @objc func refreshTheFeed(_ sender: Any) {
        videos?.shuffle()
        collectionView.reloadData()
        self.refreshControl.endRefreshing()
        self.activityIndicator.stopAnimating()
        
        print("It got shuffled")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true
        {
            print("App is Connected with internet")
        }
        else
        {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            controller.addAction(ok)
            controller.addAction(cancel)
            
            present(controller, animated: true, completion: nil)
        }
        
    }
    
    func fetchVideos() {
        self.videos = [ThumbnailDetails]()
        self.channelIdArray.shuffle()
        
        for id in channelIdArray {
            Alamofire.request(youtubeApiCall, method: .get, parameters: ["part":"snippet,contentDetails", "channelId":id, "maxResults":"15", "key":apiKey]).responseJSON { (response) in
                
                
                
                DispatchQueue.main.async {
                    self.fetchChannelThumbnail(ChannelID: id)
                    //self.refreshControl.endRefreshing()
                    //self.activityIndicator.stopAnimating()
                }
                
                if let json = response.result.value as? [String: AnyObject] {
                    for items in json["items"] as! NSArray {
                        //print("Items: \(items)")
                        
                        let video = ThumbnailDetails()
                        
                        let title = (items as AnyObject)["snippet"] as? [String: AnyObject]
                        //print("Title: \(String(describing: title))")
                        
                        let publishedDate = title!["publishedAt"] as? String
                        if let index = publishedDate?.range(of: "T1") {
                            let subString = publishedDate![..<index.lowerBound]
                            video.uploadDate = "Published Date: \(String(subString))"
                            //print("Date: \(subString)")
                        }
                        
                        let contentDetails = (items as AnyObject)["contentDetails"] as? [String: AnyObject]
                        //print("Content Details: \(contentDetails)")
                        
                        var videoId = contentDetails!["upload"]?["videoId"] as? String

                        if videoId == nil {
                            let resource = contentDetails!["playlistItem"]?["resourceId"] as? [String: AnyObject]
                            videoId = resource!["videoId"] as? String ?? "nil"
                        }
                        
                        let thumbnailUrl = title!["thumbnails"] as? [String: AnyObject]
                        //print("URL: \(String(describing: thumbnailUrl))")
            
                        video.videoTitle = title!["title"] as? String
                        video.cellVideoId = videoId
                        video.channelId = id
                        video.videoImageName = thumbnailUrl!["maxres"]?["url"] as? String
                        
                        //appending the videos
                        self.videos?.append(video)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            //self.refreshControl.endRefreshing()
                            //self.activityIndicator.stopAnimating()
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                        self.shouldAnimate = false
                        self.collectionView.reloadData()
                        //self.refreshControl.endRefreshing()
                        //self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        self.videos?.shuffle()
    }
    
    func fetchChannelThumbnail(ChannelID id: String){
        
        let channel = ChannelDetails()
        
        Alamofire.request(channelApiCall, method: .get, parameters: ["part":"snippet,statistics", "id":id, "key":apiKey]).responseJSON { (response) in
            
            print("api called")
            
            if let json = response.result.value as? [String: AnyObject] {
                
                for items in json["items"] as! NSArray {
                    print("CHANNEL Items: \(items)")
                    
                    let title = (items as AnyObject)["snippet"] as? [String: AnyObject]
                    channel.channelTitle = title!["title"] as? String
                    //print("Channel Title in table view: \(String(describing: channel.channelTitle))")
                    
                    let thumbnailUrl = title!["thumbnails"] as? [String: AnyObject]
                    let highResUrl = thumbnailUrl!["high"]?["url"] as? String
                    print("Channel Image URL: \(String(describing: highResUrl))")
                    channel.channelImageName = highResUrl
                    
                }
            }
        }
        
        //print("Image Name \(channel.channelImageName)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (view.frame.width - 16 - 16) * 9 / 16
        return CGSize(width: UIScreen.main.bounds.width, height: height + 16 + 68)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailedCell
        
        cell.video = videos![indexPath.item]
        
        if shouldAnimate {
            cell.showAnimatedGradientSkeleton()
        } else {
            cell.hideSkeleton()
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCell = videos![indexPath.item]
        
        Alamofire.request(videoApiCall, method: .get, parameters: ["part":"snippet,statistics", "id":selectedCell!.cellVideoId!, "key":apiKey]).responseJSON { (response) in
            
            if let json = response.result.value as? [String: AnyObject] {
                
                for items in json["items"] as! NSArray {
                    //print("Items of Video ID: \(items)")
                    
                    let statistics = (items as AnyObject)["statistics"] as? [String: AnyObject]
                    let viewCount = statistics!["viewCount"] as? String
                    //print("View Counts: \(viewCount)")
                    self.selectedCell!.numberofViews = viewCount
                }
            }
        }
        self.performSegue(withIdentifier: "goToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueDestination = segue.destination as? VideoCellVIewController
        
        segueDestination?.videoDetails = self.selectedCell
        //segueDestination?.channelId = self.channelId
    }
    
}
