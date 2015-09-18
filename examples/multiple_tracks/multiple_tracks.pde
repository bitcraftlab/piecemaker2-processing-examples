
// More complex example loading multiple tracks from
// "One Flat Thing reproduced" by William Forsythe.


import java.util.Properties;
import java.util.Date;

import org.piecemaker2.api.*;
import org.piecemaker2.models.*;

import processing.video.*;

// Access the API
PieceMakerApi api;

// Events for Callbacks
org.piecemaker2.models.Event videoEvent;
org.piecemaker2.models.Event dataEvent;

// Data is a 3D-Array of measurements (Frame, Track, Channel)

// - Each frame corresponds to one tick in time,
// - The trajectory of each dancer is contained in a channel that contains several tracks.
// - There is one track for each coordinate (x-coordinate, y-coordinate)

float[][][] data;

Movie video;
boolean paused = false;

// length of each trail
int trailSize = 500;

// Ringbuffer of trails, containing previous values (Frame, Track, Channel)
float[][][] trails;
int trailIndex = 0;
int channels;

boolean loaded = false;

// window dimensions
int width, height; 
int frame;

// diameter of the canvas
int dmap; 

// gap around canvas and video
int gap = 10; 

void setup () {

  // adjust window and canvas dimensions to the video size
  height = videoHeight + 2 * gap;
  dmap = videoHeight;
  width = videoWidth + 3 * gap + dmap;
    
  // create window
  size(width, height);

  // get video from the server if it's not in the data folder yet ...
  get_video(videoServer, videoTitle);
  
  // get channels + tracks from the server, in case they are not in the data folder yet.
  get_data();
 
  // let the video trigger the redraw
  // noLoop();

}



void draw () {
  
  println(frameRate);

  if (loaded) {

    background(255);
    image(video, gap, gap);
    markVideo();
    
    // draw canvas
    
    pushMatrix();
    translate(2 * gap + videoWidth, gap);
  
    fill(200); noStroke();
    rect(0, 0, dmap, dmap);

    drawTrails();
    drawDancers();
    
    
    popMatrix();

  } else {
    
    // indicate that the video is still loading
    background( #994433 );
  
  }

}


void movieEvent ( Movie mov ) {
  
  // read the current movie frame
  mov.read();
  
  // increase frame counter
  frame++;
  
  // update trails
  if(data != null) updateTrails();
  
  redraw();
  
}


void drawDancers() {
  
  fill(0, 100);
  noStroke();
  
  for(int j = 0; j < channels; j++) {
    float x = mapX(data[frame][0][j]);
    float z = mapZ(data[frame][2][j]); 
    ellipse(x, z, 12, 12);
  }
  
}


void markVideo() {
  
  fill(255, 100);
  strokeWeight(3);
  stroke(255, 100);
  
  for(int j = 0; j < channels; j++) {
    
    float x = data[frame][0][j];
    float y = data[frame][1][j];
    float z = data[frame][2][j];
    
    float vx = videoX(x, y, z);
    float vy = videoY(x, y, z);
    float vr = videoR(x, y, z);
    
    ellipse(vx, vy, vr, vr);
    
  }
  
}

void drawTrails() {
    
  noFill();
  
  for(int c = 0; c < channels; c++) {
    
    // TODO: individual stroke for each channel
    stroke(0, 20);
    strokeWeight(10);
    strokeJoin(ROUND);
    
    beginShape();
    
    for(int i = 0; i < trailSize; i++) {
      
      int idx = (frame + i + 1) % trailSize;
   
      float x0 = trails[idx][0][c];
      float z0 = trails[idx][2][c];
      
      // ignore 0-values (hacky-di-hack)
      if(x0 != 0 && z0 != 0) {
        vertex(mapX(x0), mapZ(z0));
      }

    } 
    
    endShape();
    
  }   
}

// map data to canvas coordinates
float mapX(float x) {
  return map(x, xMin, xMax, 0, dmap);
}
float mapZ(float z) {
  return map(z, zMax, zMin, 0, dmap);
}

// map data to video coordinates
float videoX(float x, float y, float z) {
  return map(x, -8, 8, 0, videoWidth);
}
float videoY(float x, float y, float z) {
  return map(z, 8, -8, 0 - (videoWidth-videoHeight)/2, videoHeight + (videoWidth-videoHeight)/2);
}
float videoR(float x, float y, float z) {
  return y * 100;
}


void updateTrails() {
  int idx = frame % trailSize;
  for(int c = 0; c < channels; c++) {
    trails[idx][0][c] = data[frame][0][c];
    trails[idx][1][c] = data[frame][1][c];
    trails[idx][2][c] = data[frame][2][c];
  }
}

void keyPressed() {
  switch(key) {
    case ' ':
      paused = !paused;
      if(paused) {
        video.pause();
      } else {
        video.play(); 
      }
      break;
      
    case '-': 
      eventTimeOffset -= 0.1;
      break;
      
    case '+':
      eventTimeOffset += 0.1;
      break;
   
    case 'p':
      println("OFFSET: " + eventTimeOffset);
      break;
   
  } 
  
}


