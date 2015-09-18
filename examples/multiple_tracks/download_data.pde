
void download_data() {
  
  // initialize the client with host and API-Key
  api = new PieceMakerApi(this, apiHost, apiKey);

  // trigger loading of group
  api.listEventsOfType(groupId, "video", api.createCallback("groupLoaded"));
  
}
  

// group loaded callback
void groupLoaded ( org.piecemaker2.models.Event[] videos ) {
  
  println("Loaded group " + groupId);
  
  // find the event corresponding to the video
  for (org.piecemaker2.models.Event v : videos) {
    if (v.fields.get("title").equals(videoTitle)) {
      
      println("Loading Video " + videoTitle);
      videoEvent = v;
      
      // list all events that intersect with the video
      api.listEventsForTimespan( groupId, 
                                 v.utc_timestamp, 
                                 new Date( v.utc_timestamp.getTime() + (long)(v.duration * 1000) ), 
                                 api.INTERSECTING,
                                 api.createCallback("eventsLoaded") );
      break;
      
    }
  }
}


// context events loaded callback
void eventsLoaded (org.piecemaker2.models.Event[] events) {

  // create a list of events
  JSONArray eventList = new JSONArray();
  int idx = 0;
  
  println("Events loaded ...");
  for (org.piecemaker2.models.Event e : events) {

    // Filter events by type
    if (e.type.equals("pma-channel")) {
      dataEvent = e;
      println( "ID: " + e.id + " / Title: " + e.fields.get("title") );
      
      String host = "api.piecemeta.com"; // (String) (e.fields.get("pma_host"));
      String uuid = (String) (e.fields.get("pma_uuid"));
      
      println("Channel: " + uuid);
      
      // add this channel to our list
      eventList.setString(idx++, uuid);
      
      // download all streams for this channel
      loadChannelAndStreams(host, uuid);
      
      // break;
    }

  }
  
  // save all the filtered events to disk
  println("Saving list of " + eventList.size() + " channels to disk");
  saveJSONArray(eventList, dataFolder + videoTitle + "-channels.json");
  
}


// loading the actual data from Piecemeta
void loadChannelAndStreams (String host, String channelUUID) {
  
  // load channel meta data
  JSONObject channel = loadJSONObject( "http://"+ host +"/channels/"+channelUUID+".json" );
  
  // load stream meta data
  JSONArray streams = loadJSONArray( "http://"+ host +"/channels/"+channelUUID+"/streams.json" );
  
  // save data
  println("Saving JSON to the data folder");
  saveJSONObject(channel, dataFolder + channelUUID + ".json");
  saveJSONArray(streams, dataFolder + channelUUID + "-streams.json");
  
  println( "channel \"" + channel.getString("title") + "\" / streams: " + streams.size() );
  
  for (int i = 0, k = streams.size(); i < k; i++) {
    
    JSONObject streamInfo = streams.getJSONObject(i);
    String streamUUID = streamInfo.getString( "uuid" );
    
    // load stream of floats 
    // JSONObject stream = loadJSONObject( "http://"+ host +"/streams/"+ streamUUID + ".json" + "?skip=2" );
    JSONObject stream = loadJSONObject( "http://"+ host +"/streams/"+ streamUUID + ".json");
     
    // save stream to data folder
    saveJSONObject(stream, dataFolder + streamUUID + ".json");
    
    // read data into local data structure
    // readStreamData(stream);
    
  }

  
}

