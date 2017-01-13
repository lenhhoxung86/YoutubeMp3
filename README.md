# YoutubeMp3
This app has three main features:
- Search a video from YouTube
- Stream the video as audio file
- Download the audio from YouTube to the device, then user can listen offline. The actual format of the downloaded audio is m4a (the name of the app my confuse you)

To run the app:
- Install dependencies via Cocoapods: pod install
- Set up YouTube API key
    + Go to https://console.developers.google.com/apis/dashboard and create an app
    + Enable YouTube API, get the API key then open file "YoutubeHelper.swift" and replace "YOUR_API_KEY" by your key
- Personalize your channel (Optional): Go to SearchVC.swift and change yt_channel_id to id of your YouTube channel ID

Warning: This app use XCDYouTubeKit, which doesn't confront to YouTube's policy
If you like the app, please star this repository.
Enjoy.
