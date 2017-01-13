//
//  YTVideo.swift
//  MP3Lover
//
//  Created by tien dh on 12/18/16.
//  Copyright © 2016 tien dh. All rights reserved.
//

import Foundation

class YTVideo {
    var videoID = ""
    var videoTitle = ""
    var videoDescription = ""
    var videoThumbnail = ""
    
    init(videoID:String,videoTitle:String,videoDescription:String,videoThumbnail:String) {
        self.videoID = videoID
        self.videoTitle = videoTitle
        self.videoDescription = videoDescription
        self.videoThumbnail = videoThumbnail
    }
}
