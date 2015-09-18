
// Check if video is avaialble, and download it in case it's not.
// Downloading the full video to memory. This might be a problem for larger videos...
  
void get_video(String videoServer, String videoTitle) {

  String ending = ".mp4"; 
  String filename = dataFolder + videoTitle + ending;
  File f = new File(sketchPath(filename));
  boolean downloaded = f.exists();   // did we download the video already?
  
  if(!downloaded) {

     // play video after downloading
     println("The video is not in your data folder!");
     download_video(videoServer, videoTitle + ending);
     
  } else {
    
    // play video immediately
    println("Using video from data folder");
    playVideo();
    
  }
  
}


void download_video(String videoServer, String filename) {

    String videoURL = videoServer + "/" + filename;

    println("Downloading video from " + videoURL);
    println("Please be patient, this may take a while");
    
    byte[] bytes = loadBytes(videoURL);
    
    println("Saving video to your data folder");
    saveBytes(dataFolder + filename, bytes); 
    
    playVideo();
    
}


void playVideo() {
  
  String filename = groupId + "/" + videoTitle + ".mp4";
  video = new Movie(this, filename);
  video.play();
  
  //eventTimeOffset = (dataEvent.utc_timestamp.getTime() - videoEvent.utc_timestamp.getTime()) / 1000.0;
  loaded = true;
  
  // skip the intro ...
  video.jump(startTime);
  
  frame =  int( (video.time() - eventTimeOffset) * 25.0 );
  
}

  
