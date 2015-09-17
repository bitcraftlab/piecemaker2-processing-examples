
import org.piecemaker2.api.*;
import org.piecemaker2.models.*;

import java.util.Properties;
import java.util.Date;

PieceMakerApi api;

void setup ()
{
  size( 400, 200 );
  
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
  if ( apiKey != null ) 
  {
    background( #669933 );
  } else {
    background( #994433 );
  }
}

// group loaded callback
void groupLoaded ( org.piecemaker2.models.Event[] videos )
{
  println("Loaded Group " + groupId);
  for ( org.piecemaker2.models.Event v : videos )
  {
    if ( v.fields.get("title").equals(videoTitle) )
    {
      println("Found video: \"" + videoTitle + "\"");
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
    println( "stream \"" + stream.getString("title") + "\" / frames: " + stream.getJSONArray("frames").size() );
  }
}
