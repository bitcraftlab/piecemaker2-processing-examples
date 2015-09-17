/**
 *  fjenett - 2015
 */
 
import org.piecemaker2.api.*;
import org.piecemaker2.models.*;

import java.util.Properties;
import java.util.Date;

import processing.video.*;

PieceMakerApi api;
org.piecemaker2.models.Event videoEvent, dataEvent;

float eventTimeOffset;
float[][] travelPath;
Movie video;

float[][] trail = new float[20][2];

boolean loaded = false;

void setup ()
{
  size( 1000, 360 );
  
  // check if video is avaialble, and download it in case it's not.
  
  String filename = videoTitle + ".mp4";
  File f = new File(dataPath(filename));
  
  if(!f.exists()) {
    
    println("The video is not in your data folder!");
    String videoURL = videoServer + "/" + filename;
    

    println("Downloading it from " + videoURL);
    println("Please be patient, this may take a while");
    
    // Downloading the full video to memory. This might be a problem for larger videos...
    byte[] bytes = loadBytes(videoURL);
    
    println("Saving video to your data folder");
    saveBytes("data/" + filename, bytes);
    
  }
  
  // initialize the client with host and API-Key
  api = new PieceMakerApi( this, apiHost, apiKey );
  
  // trigger loading of group
  api.listEventsOfType( groupId, "video", api.createCallback( "groupLoaded" ) );
  
  fill( 255 );
  textSize( 24 );
  textAlign( CENTER );

}

void draw ()
{
  if ( loaded ) 
  {
    background( 255 );
    
    image( video, 0,0 );
    fill( 200 );
    noStroke();
    rect( 650, 10, 340, 340 );
    
    int frameNum = int( (video.time()-eventTimeOffset) * 25.0 );
    if ( frameNum >= 0 && frameNum < travelPath.length )
    {
      float x = map(travelPath[frameNum][0],0,12,0,340),
            y = map(travelPath[frameNum][1],0,12,0,340);
      
      if ( dist(x,y,trail[0][0],trail[0][1]) > 3 )
      {
        float[][] tmp = new float[trail.length][2];
        for ( int i = 1; i < trail.length; i++ ) {
          tmp[i][0] = trail[i-1][0];
          tmp[i][1] = trail[i-1][1];
        }
        trail = tmp;
        trail[0][0] = x;
        trail[0][1] = y;
      }
      
      noFill();
      stroke(0);
      beginShape();
      for ( float[] p : trail )
      {
        vertex( 650 + p[0], 350 - p[1] );
      }
      endShape();
      
      fill( 0 );
      noStroke();
      ellipse( 650 + x, 350 - y, 5, 5 );
    }
    
  } else {
    background( #994433 );
  }
}

// group loaded callback
void groupLoaded ( org.piecemaker2.models.Event[] videos )
{
  for ( org.piecemaker2.models.Event v : videos )
  {
    if ( v.fields.get("title").equals(videoTitle) )
    {
      videoEvent = v;
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
void eventsLoaded ( org.piecemaker2.models.Event[] events ) 
{
  for ( org.piecemaker2.models.Event e : events ) 
  {
    if ( e.type.equals("data") )
    {
      dataEvent = e;
      println( "ID: " + e.id + " / Title: " + e.fields.get("title") );
      
      String host = (String)e.fields.get("pma-server"), 
             uuid = (String)e.fields.get("pma-channel-uuid");
      
      loadChannelAndStreams( host,uuid );
      
      break;
    }
  }
}

// loading the actual data from Piecemeta
void loadChannelAndStreams ( String host, String channelUUID )
{
  JSONObject channel = loadJSONObject( "http://"+host+"/channels/"+channelUUID+".json" );
  JSONArray streams = loadJSONArray( "http://"+host+"/channels/"+channelUUID+"/streams.json" );
  
  println( "channel \"" + channel.getString("title") + "\" / streams: " + streams.size() );
  
  for ( int i = 0, k = streams.size(); i < k; i++ )
  {
    JSONObject streamInfo = streams.getJSONObject(i);
    String streamUUID = streamInfo.getString( "uuid" );
    JSONObject stream = loadJSONObject( "http://"+host+"/streams/"+streamUUID+".json" + "?skip=2" );
    
    String title = stream.getString("title");
    int dimension = title.equals("x") ? 0 : (title.equals("y") ? 1 : 2);
    JSONArray frames = stream.getJSONArray("frames");
    println( "stream \"" + title + "\" / frames: " + frames.size() );
    
    if ( travelPath == null )
    {
      travelPath = new float[frames.size()][3];
    }
    
    float minX, maxX, minY, maxY, minZ, maxZ;
    for ( int ii = 0, kk = frames.size(); ii < kk; ii++ )
    {
      travelPath[ii][dimension] = frames.getFloat( ii );
    }
  }

  
  video = new Movie( this, videoTitle + ".mp4" );
  video.play();
  
  eventTimeOffset = (dataEvent.utc_timestamp.getTime() - videoEvent.utc_timestamp.getTime()) / 1000.0;
  
  loaded = true;
}

void movieEvent ( Movie mov )
{
  mov.read();
}

