
// URL of the Peacemaker 2 Server
String apiHost = "http://piecemaker2-api-public.herokuapp.com";

// Group 51: One Flat Thing reproduced (William Forsythe)
int groupId = 51; 

// Video Title
String videoTitle ="TopProRes";

// Video Server - no trailing slash!
String videoServer = "https://d35vpnmjdsiejq.cloudfront.net/synco/piecemaker";

// Video Dimensions (we should extract those from the video  ...)
int videoWidth = 854;
int videoHeight = 480;

// organize data by group id's
String dataFolder = "data/" + str(groupId) + "/";

// jump right into the video, yeah!
float startTime = 25.0;

// These values are guesswork ...
float xMin = -8, xMax = +8;
float zMin = -8, zMax = +8;
float eventTimeOffset = -5.2;

// My secret API key (Put this into "secret.pde", so it does not show up on github)
// String apiKey =  ... ;



