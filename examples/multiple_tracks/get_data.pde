
//float xMax = Float.NEGATIVE_INFINITY;
//float xMin = Float.POSITIVE_INFINITY;

//float yMax = Float.NEGATIVE_INFINITY;
//float yMin = Float.POSITIVE_INFINITY;


void get_data() {
  
  
  // Check if the list of channels has already been downloaded
  String filename = dataFolder + videoTitle + "-channels.json";
  File f = new File(sketchPath(filename));
  boolean downloaded = f.exists();   
  
  if(downloaded) {
    
    // load list of all channels
    JSONArray channelList = loadJSONArray(dataFolder + videoTitle + "-channels.json");
    channels = channelList.size();
    
    println("Found " + channels + " channels");
    
    // iterate over all channels
    for (int i = 0, n = channelList.size(); i < n; i++ ) {
      
      // get channel ID
      String channelUUID = channelList.getString(i);
      
      // load channel meta data
      JSONObject channel = loadJSONObject(dataFolder + channelUUID + ".json");
    
      // load stream meta data
      JSONArray streams = loadJSONArray(dataFolder + channelUUID + "-streams.json");
      
      println("------------------------------");
      println("Channel \"" + channel.getString("title") + "\" / streams: " + streams.size());
      
      // get streams for each channel
      for (int j = 0, m = streams.size(); j < m; j++ ) {
        
        JSONObject streamInfo = streams.getJSONObject(j);
        String streamUUID = streamInfo.getString( "uuid" );
        
        // load stream from data folder
        JSONObject stream = loadJSONObject(dataFolder + streamUUID + ".json");
        
        // get frames for each stream
        readStreamData(i, stream);
      
      }
    }     
    
  } else {
    
    download_data(); 
    
  }  
}


void readStreamData(int channel,  JSONObject stream) {
  
    String title = stream.getString("title");
    char ch = title.charAt(0);
    int dimension = -1;
    
    switch(ch) {
      case 'x': 
        dimension = 0; 
        break;
      case 'y':
        dimension = 1;
        break;
      case '?':
        dimension = 2;
        break;
    } 

    
    // ignore everything except x and ? and y
    if(dimension < 0) {
      return; 
    }
    
    JSONArray frames = stream.getJSONArray("frames");
    println( "  Stream \"" + title + "\" / Frames: " + frames.size() );
    
    // if we haven't done this yet, create the data array
    if (data == null) {
      data = new float[frames.size()][3][channels];
      trails = new float[trailSize][3][channels];
    }
    
    // read data sample
    for (int frame = 0, n = frames.size(); frame < n; frame++ ) {
      
      float sample = frames.getFloat(frame);
      
      /*
      if(dimension == 0) {
        zMin = min(xMin, sample);
        zMax = max(xMax, sample);
      }
      
      if(dimension == 1) {
        zMin = min(yMin, sample);
        zMax = max(yMax, sample); 
      }
      */
      
      data[frame][dimension][channel] = frames.getFloat(frame);
    }
}

