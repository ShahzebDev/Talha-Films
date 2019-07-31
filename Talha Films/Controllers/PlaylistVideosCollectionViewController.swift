//
//  PlaylistVideosCollectionViewController.swift
//  Talha Films
//
//  Created by Moazzam Tahir on 29/05/2019.
//  Copyright © 2019 Moazzam Tahir. All rights reserved.
//

import UIKit
import Alamofire

class PlaylistVideosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var playlistVideos: [ThumbnailDetails]?
    var playlistId: String?
    var playlistChannelId: String?
    
    var playlistChannelImageName: String?
    
    var selectedCell: ThumbnailDetails?
    
    private let playlistVideoApiKey = "AIzaSyB5V3VCOAOXmQgN4hbrNdqydo-JxTkeJvA"

    
    let playlistItemsApiUrl = "https://www.googleapis.com/youtube/v3/playlistItems"
    let videoApiUrl = "https://www.googleapis.com/youtube/v3/videos?"
    let youtubeChannelURL = "https://www.googleapis.com/youtube/v3/channels?"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("In playlist view controller")
        
        navigationItem.title = "Playlist Videos"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        // Register cell classes
        self.collectionView.register(PlaylistVideosUI.self, forCellWithReuseIdentifier: "cell")
        
        fetchVideos()
    }
    
    func fetchVideos(){
        self.playlistVideos = [ThumbnailDetails]()
        //et id = playlistId
        Alamofire.request(playlistItemsApiUrl, method: .get, parameters: ["part":"snippet,contentDetails", "maxResults":"30" ,"playlistId":playlistId ?? "nil", "key":playlistVideoApiKey]).responseJSON { (response) in
            
            if let json = response.result.value as? [String: AnyObject] {
                for items in json["items"] as! NSArray {
                    //print("Items of Video ID: \(items)")
                    let video = ThumbnailDetails()
                    
                    let title = (items as AnyObject)["snippet"] as? [String: AnyObject]
                    let thumbnailUrl = title!["thumbnails"] as? [String: AnyObject]
                    let contentDetails = (items as AnyObject)["contentDetails"] as? [String: AnyObject]
                    
                    if thumbnailUrl != nil {
                        
                        let publishedDate = title!["publishedAt"] as? String
                        if let index = publishedDate?.range(of: "T1") {
                            let subString = publishedDate![..<index.lowerBound]
                            video.uploadDate = "Published Date: \(String(subString))"
                            //print("Date: \(subString)")
                        }
                        
                        var videoId = contentDetails!["videoId"] as? String
                        
                        if videoId == nil {
                            let resource = contentDetails!["playlistItem"]?["resourceId"] as? [String: AnyObject]
                            videoId = resource!["videoId"] as? String ?? "nil"
                        }
                        
                        video.videoTitle = title!["title"] as? String
                        video.videoImageName = thumbnailUrl!["maxres"]?["url"] as? String
                        video.cellVideoId = videoId
                        video.channelImageName = self.playlistChannelImageName
                        video.channelId = title!["channelId"] as? String
                        
                        self.playlistVideos?.append(video)
                        //print("Video: \(video)")
                    }
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (view.frame.width - 16 - 16) * 9 / 16
        return CGSize(width: UIScreen.main.bounds.width, height: height + 16 + 68)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return playlistVideos?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PlaylistVideosUI
        
        // Configure the cell
        cell.videos = playlistVideos![indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCell = playlistVideos![indexPath.item]
        
        Alamofire.request(videoApiUrl, method: .get, parameters: ["part":"statistics", "id":selectedCell!.cellVideoId!, "key":playlistVideoApiKey]).responseJSON { (response) in
            
            if let json = response.result.value as? [String: AnyObject] {
                
                for items in json["items"] as! NSArray {
                    
                    let statistics = (items as AnyObject)["statistics"] as? [String: AnyObject]
                    let viewCount = statistics!["viewCount"] as? String
                    //print("View Counts: \(viewCount)")
                    self.selectedCell!.numberofViews = viewCount
        
                }
            }
        }
        self.performSegue(withIdentifier: "goToVideo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueDestination = segue.destination as? VideoCellVIewController
        
        segueDestination?.videoDetails = self.selectedCell
        //segueDestination?.channelId = self.channelId
    }
}
