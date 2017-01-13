//
//  YoutubeHelper.swift
//  MP3Lover
//
//  Created by tien dh on 12/18/16.
//  Copyright © 2016 tien dh. All rights reserved.
//

import Foundation
import Alamofire

let YOUTUBE_API_KEY = "AIzaSyAiKurNj0sQXQx1cguGglH6yRoz5RPDClw"
let YOUTUBE_API_BASE_URL = "https://www.googleapis.com/youtube/v3/"
let MAX_RESULT = 20


class YoutubeHelper {
    func getYoutubeVideosFromPlaylist(playlistID:String,callback:@escaping ([YTVideo])->()) {
        let url = YOUTUBE_API_BASE_URL + "playlistItems?part=snippet&maxResults=20&playlistId=" + playlistID + "&key=" + YOUTUBE_API_KEY
        Alamofire.request(url).responseJSON { response in
            if let JSON = response.result.value {
                var ytVideos = [YTVideo]()
                if let videos = JSON as? [String: Any] {
                    let items = videos["items"] as! [NSDictionary]
                    for item in items {
                        if let snippet = item["snippet"] as? [String: Any] {
                            if let resourceID = snippet["resourceId"] as? [String: Any] {
                                if let videoID: String = resourceID["videoId"] as? String {
                                    if let videoTitle = snippet["title"] as? String {
                                        let videoDescription = snippet["description"] as! String
                                        let videoThumbnail = ((snippet["thumbnails"] as! NSDictionary)["default"] as! NSDictionary)["url"] as! String
                                        let video = YTVideo(videoID: videoID, videoTitle: videoTitle, videoDescription: videoDescription, videoThumbnail: videoThumbnail)
                                        ytVideos.append(video)
                                    }
                                }
                            }
                        }
                    }
                }
                callback(ytVideos)
            }
        }
    }
    
    func searchYoutubeVideos(keyword:String,callback:@escaping ([YTVideo])->()) {
        var url:String = YOUTUBE_API_BASE_URL + "search?part=snippet&maxResults=20&q=" + keyword + "&key=" + YOUTUBE_API_KEY
        url = url.addingPercentEncoding(withAllowedCharacters:  .urlQueryAllowed)!
        Alamofire.request(url).responseJSON { response in
            if let JSON = response.result.value {
                let videos = JSON as! NSDictionary
                var ytVideos = [YTVideo]()
                let items = videos["items"] as! [NSDictionary]
                for item in items {
                    if let snippet = item["snippet"] as? [String: Any] {
                        if let id_dict = item["id"] as? [String: Any] {
                            if let videoID: String = id_dict["videoId"] as? String {
                                let videoTitle = snippet["title"] as! String
                                let videoDescription = snippet["description"] as! String
                                let videoThumbnail = ((snippet["thumbnails"] as! NSDictionary)["default"] as! NSDictionary)["url"] as! String
                                let video = YTVideo(videoID: videoID, videoTitle: videoTitle, videoDescription: videoDescription, videoThumbnail: videoThumbnail)
                                    ytVideos.append(video)
                            }
                        }
                    }
                }
                callback(ytVideos)
            }
        }
    }
    
    func downloadYoutubeVideoFromURL(url:String,progressCallback: @escaping (Float)->(),callback:@escaping ()->()) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(url, to: destination).downloadProgress { progress in
            progressCallback(Float(progress.fractionCompleted))
        }.responseData { response in
            callback()
        }
    }
    
}


