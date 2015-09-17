/**
 *  Piecemaker basics:
 *  logging in and how to retrieve the API KEY
 *
 *  fjenett 2015
 */

import org.piecemaker2.api.*;
import org.piecemaker2.models.*;
import java.util.Properties;

String apiHost = "http://piecemaker2-api-public.herokuapp.com";

PieceMakerApi api;

String apiKey;

void setup ()
{
  size( 400, 200 );
  
  api = new PieceMakerApi( this, apiHost, null );
  
  api.login( userName, passWord, api.createCallback( "loggedIn" ) );
  
  fill( 255 );
  textSize( 24 );
  textAlign( CENTER );
}

void draw ()
{
  if ( apiKey != null ) 
  {
    background( #669933 );
    text( apiKey, width/2, height/2+4 );
  } else {
    background( #994433 );
    text( "...", width/2, height/2+4 );
  }
}

void loggedIn ( String apiKeyIn )
{
  println( "Your API-KEY is " + apiKeyIn );
  
  apiKey = apiKeyIn;
  
  api.whoAmI( api.createCallback("iAmLoaded") );
}

void iAmLoaded ( User user )
{
  // store in a properties file for later use in other sketches
  Properties props = new Properties();
  props.setProperty("api_key",apiKey);
  props.setProperty("user_id",str(user.id));
  props.setProperty("api_host",apiHost);
  try { props.save( createOutput( "pm2.properties" ), "" ); } catch (Exception e) {}
}
