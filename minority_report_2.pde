/* --------------------------------------------------------------------------
 * SimpleOpenNI Hands3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  02/27/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 * This demos shows how to use the gesture/hand generator.
 * It's not the most reliable yet, a two hands example will follow
 * ----------------------------------------------------------------------------
 */
 
import SimpleOpenNI.*;
//import processing.opengl.*;
 
SimpleOpenNI kinect;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);
boolean      handsTrackFlag = false;
PVector      handVec = new PVector();
ArrayList    handVecList = new ArrayList();
int          handVecListSize = 30;
String       lastGesture = "";
 
// Image variable
PImage img1;
PImage img2;
PImage img3; 
 
void setup()
{
  size(600, 480);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  //size(1024,768,OPENGL); 
 
  kinect = new SimpleOpenNI(this);
 
  // disable mirror
  kinect.setMirror(true);
 
  // enable depthMap generation 
  kinect.enableDepth();
 
  // enable hands + gesture generation
  kinect.enableGesture();
  kinect.enableHands();
 
  // add focus gestures  / here i do have some problems on the mac, i only recognize raiseHand ? Maybe cpu performance ?
  kinect.addGesture("Wave");
  kinect.addGesture("Click");
  kinect.addGesture("RaiseHand");
 
  // set how smooth the hand capturing should be
  kinect.setSmoothingHands(.5);
 
  stroke(255, 255, 255);
  smooth();
 
  perspective(95.0f, 
  float(width)/float(height), 
  10.0f, 150000.0f);
  
  // load images
  img1 = loadImage("image1.jpg");
}
 
void draw()
{
  // update kinect images
  kinect.update();
  // set background black
  background(0);
  
  //red point
  stroke(255, 0, 0);
  strokeWeight(5);
  
  kinect.convertRealWorldToProjective(handVec, handVec);
  point(handVec.x, handVec.y);
  println(handVec.x + " " + handVec.y + " " + handVec.z);
  
  minorityReport();
}
 
 
// -----------------------------------------------------------------
// hand events
 
void onCreateHands(int handId, PVector pos, float time)
{
  handVec = pos;
}
 
void onUpdateHands(int handId, PVector pos, float time)
{
  handVec = pos;
}
 
void onDestroyHands(int handId, float time)
{
}
 
// -----------------------------------------------------------------
// gesture events
 
void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{ 
  lastGesture = strGesture;
  kinect.removeGesture(strGesture); 
  kinect.startTrackingHands(endPosition);
}
 
void onProgressGesture(String strGesture, PVector position, float progress)
{
}

boolean zThreshold = false;
boolean isPictureMoving = false;
int currentPostionXImg1 = 200;
int currentPostionYImg1 = 200;
int currentSize = 1;
int smallSize = 100;
int largeSize = 110;
int pickUPZ = 1450;
int offset = 50;
 
void minorityReport()
{
  if (!(isPictureMoving) & handVec.x >= currentPostionXImg1 & handVec.x <= currentPostionXImg1 + smallSize
           & handVec.y >= currentPostionYImg1 & handVec.y >= currentPostionYImg1 + smallSize
           & handVec.z <= pickUPZ & !(zThreshold))
  {
    println("A");
    currentPostionXImg1 = int(handVec.x-currentPostionXImg1/2);
    currentPostionYImg1 = int(handVec.y-currentPostionYImg1/2);
    image(img1,currentPostionXImg1,currentPostionYImg1,largeSize,largeSize);
    isPictureMoving = true;
    zThreshold = false;
  }
  else if (isPictureMoving & handVec.z <= pickUPZ & !(zThreshold))
  {
    println("B");
    currentPostionXImg1 = int(handVec.x-currentPostionXImg1/2);
    currentPostionYImg1 = int(handVec.y-currentPostionYImg1/2);
    image(img1,currentPostionXImg1,currentPostionYImg1,largeSize,largeSize);
    isPictureMoving = true;
    zThreshold = false;
  } 
  else if (isPictureMoving & handVec.z > pickUPZ & !(zThreshold))
  {
    println("C");
    currentPostionXImg1 = int(handVec.x-currentPostionXImg1/2);
    currentPostionYImg1 = int(handVec.y-currentPostionYImg1/2);
    image(img1,currentPostionXImg1,currentPostionYImg1,largeSize,largeSize);
    isPictureMoving = true;
    zThreshold = true;  
  }
  else if (isPictureMoving & zThreshold & handVec.z > pickUPZ)
  {
    println("D");
    currentPostionXImg1 = int(handVec.x-currentPostionXImg1/2);
    currentPostionYImg1 = int(handVec.y-currentPostionYImg1/2);
    image(img1,currentPostionXImg1,currentPostionYImg1,largeSize,largeSize);
    isPictureMoving = true;
    zThreshold = true;
  }
  else if (isPictureMoving & zThreshold & handVec.z <= pickUPZ)
  {
    println("E");
    image(img1,currentPostionXImg1,currentPostionYImg1,smallSize,smallSize);
    isPictureMoving = false;
    zThreshold = true;
  }
  else if (isPictureMoving & zThreshold & handVec.z > pickUPZ)
  {
    println("F");
    image(img1,currentPostionXImg1,currentPostionYImg1,smallSize,smallSize);
    isPictureMoving = false;
    zThreshold = false;
  }
  else
  {
    println("G");
    image(img1,currentPostionXImg1,currentPostionYImg1,smallSize,smallSize);
    isPictureMoving = false;
    zThreshold = false;
  }
}
