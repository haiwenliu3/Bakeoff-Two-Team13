import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

boolean checkDrag;
boolean onCenter;
float diffX;
float diffY;

boolean translateMode = false;
boolean resizingMode = false;
//float screenZ = 100;
//float screenZ = 100;

PImage rotate_left;
PImage rotate_right;
float rotate_left_button_x;
float rotate_left_button_y;
float rotate_right_button_x;
float rotate_right_button_y;

float dragger_x;
float dragger_y1;
float dragger_y2;
boolean rotatingMode = false;

String msg = "Drag center of square";

//boolean closeDist = false;
//boolean closeRotation = false;
//boolean closeZ = false;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

void setup() {
  size(1000, 800); 

  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=0; i<trialCount; i++)
  {
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    Target t = targets.get(i);
    translate(t.x, t.y); //center the drawing coordinates to the center of the screen
    rotate(radians(t.rotation));

    if (trialIndex==i) {
      fill(255, 0, 0, 192); //set color to semi translucent
      rect(0, 0, t.z, t.z);
      fill(255, 255, 255, 192);
      circle(0,0,5);
      //stroke(255, 0, 0);
      //rect(0, 0, t.z, t.z);
      //noStroke();
      
      // arrow from cursor square to target square
      //stroke(126);
      //line(screenTransX, screenTransY, t.x, t.y);
      //println(t.x);
      //println(t.y);
      //noStroke();
    }
    else{
    fill(128, 60, 60, 128); //set color to semi translucent
    rect(0, 0, t.z, t.z);
    fill(255, 255, 255, 128);
    circle(0,0,5);
    }
    popMatrix();
  }

  //===========DRAW CURSOR SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY);
  rotate(radians(screenRotation));
  noFill();
  strokeWeight(3f);
  stroke(160);
  
  for(int i=0; i<trialCount; i++) {
    Target t = targets.get(i);  
    boolean closeDist = dist(t.x + width/2, t.y+height/2, screenTransX+width/2, screenTransY+height/2)<inchToPix(.05f); //has to be within +-0.05"
    boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation, screenRotation)<=5;
    boolean closeZ = abs(t.z - screenZ)<inchToPix(.05f); //has to be within +-0.05"
    if (closeDist) {
      msg = "Now rescale.";
      stroke(252, 240, 3);
      if (closeZ) {
        msg = "Now rotate.";
        stroke(52, 168, 50);
        if (closeRotation) {fill(250, 250, 250, 150);}
      }
    } 
    
  }
  
  Target target = targets.get(trialIndex);  
  boolean closeDist = dist(target.x + width/2, target.y+height/2, screenTransX+width/2, screenTransY+height/2)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(target.rotation, screenRotation)<=5;
  boolean closeZ = abs(target.z - screenZ)<inchToPix(.05f); //has to be within +-0.05"
  if (closeDist & closeZ & closeRotation) {
    fill(52,168,50, 192);
  } 

  rect(0, 0, screenZ, screenZ);
  

  // resizer
  if (resizingMode) {
    screenZ = constrain(2 * min(mouseX - (screenTransX+width/2), mouseY - (screenTransY+height/2)), 0.01, 1000);
  }
  

  if (rotatingMode) {
    // rotate in the direction of the angle?? - map direction (if negative) to negative radians
    // rotate proportional to the distance between cursor and original
    
    float angle = degrees(atan2(screenTransY + height/2 - mouseY,screenTransX + width/2 - mouseX));
    screenRotation = angle - 90;
    
    
  }
  
  
  // upper right corner, rotate clockwise
  // rotate buttons
  // text("rotate", width/2 - inchToPix(.8f), height - inchToPix(.8f));
  // line(rotate_left_button_x, rotate_left_button_y, mouseX - (screenTransX+width/2), mouseY - (screenTransY+height/2)); 
  //if (mousePressed && dist(rotate_left_button_x, rotate_left_button_y, mouseX - (screenTransX+width/2), mouseY - (screenTransY+height/2)) < 50){
  //  screenRotation -= 2;
  //}
  
  //if (mousePressed && dist(rotate_right_button_x, rotate_right_button_y, mouseX - (screenTransX+width/2), mouseY - (screenTransY+height/2)) < 50){
  //  screenRotation += 2;
  //}
  
  popMatrix();
  
  // draw controls to manipulate the square
  if (!translateMode) {
    // size scaler box
    rect(width/2 + screenTransX + screenZ / 2, height/2 + screenTransY + screenZ / 2, 20, 20);
    
    // rotater
  }
  
  // rotate by dragging the box around in an angle
  
  // line that is pointing in the angle of rotation (pointing up)
  dragger_x = screenTransX + width/2;
  dragger_y1 = screenTransY + height/2;
  dragger_y2 = dragger_y1 - screenZ * 3/4;
  line(dragger_x, dragger_y1, dragger_x, dragger_y2);
  // circle that user drags to rotate
  circle(dragger_x, dragger_y2, 40);
  
  //draw a line from center to the target
  fill(255);
  line(screenTransX + width/2, screenTransY + height/2, target.x + width/2, target.y + height/2);
  
  
  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, 75, inchToPix(.8f), 150, 100);
  
  // draw indicators
  // background color of indicator matches the condition
  noStroke();
 
    fill(255, 255, 255);
    text(msg, 550, 50);

  
}


void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  //text("CCW", inchToPix(.4f), inchToPix(.4f));
  //if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
    //screenRotation--;

  //upper right corner, rotate clockwise
  //text("rotate", width/2 - inchToPix(.8f), height - inchToPix(.8f));
  //line(rotate_left_button_x, rotate_left_button_y, mouseX, mouseY);
  //if (mousePressed && dist(rotate_left_button_x, rotate_left_button_y, mouseX, mouseY) < inchToPix(.8f)){
  //  screenRotation++;
  //}
  
  // text("submit", width/2 + inchToPix(.8f), height - inchToPix(.8f));
}


void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}


void mouseClicked(MouseEvent evt) {
    //check to see if user clicked middle of screen within 3 inches
  // if (dist(width/2 + inchToPix(.8f), height - inchToPix(.8f), mouseX, mouseY)<inchToPix(.8f)){
  if (evt.getCount() == 2) {
      if (userDone==false && !checkForSuccess())
        errorCount++;

      trialIndex++; //and move on to next trial

      if (trialIndex==trialCount && userDone==false)
      {
        userDone = true;
        finishTime = millis();
      }
      
      if (screenZ < 40f) screenZ = 40f;
      //screenTransX = 0;
      //screenTransY = 0;
      //screenRotation = 0;
      //screenZ = 50f;
  }
}


void mouseMoved()
{
  if (translateMode) {
    screenTransX = mouseX;
    screenTransY = mouseY;
  }
}


float diffXRotate;
float diffYRotate;
boolean checkDragRotate;
void mouseDragged(MouseEvent evt) {
  boolean is_bulb_clicked = dist(dragger_x, dragger_y2, mouseX, mouseY) < 20;
  
  
  // when user clicks on the bulb
  if (is_bulb_clicked) {
    if (!resizingMode & !checkDrag)
    rotatingMode = true;
    print("rotatingMode!");
  }
  //if (!rotatingMode) {
  //  if (!checkDragRotate) {
  //    diffXRotate = screenTransX + width/2 - mouseX;
  //    diffYRotate = screenTransY + height/2 - mouseY;
  //    checkDragRotate = true;
  //  }
  //  if (checkDragRotate) {
  //    if ((abs(diffXRotate) < (dragger_x - 50)) && (abs(diffYRotate) < (dragger_y - 50))) {
  //       // map the rotation
  //       println("REACHED");
  //    }
  //  }
  //}
  
  
  if (dist(screenTransX+width/2 + screenZ / 2, screenTransY+height/2 + screenZ / 2, mouseX, mouseY) < 10) {
    if (!rotatingMode & !checkDrag) 
    resizingMode = true;
  }
  if (!resizingMode & !rotatingMode) { //moving placement of square
    if (!checkDrag){
      diffX = screenTransX+width/2 - mouseX;
      diffY = screenTransY+height/2 - mouseY;
      checkDrag = true;
    }
    if (checkDrag) {
      if ((abs(diffX) < (screenZ/2 - inchToPix(.05f))) & (abs(diffY) < (screenZ/2 - inchToPix(.05f)))){
        float moveX = mouseX - width/2;
        float moveY = mouseY - height/2;
        screenTransX = moveX;
        screenTransY = moveY;
      }
    }
  }
}

void mouseReleased()
{
  resizingMode = false;
  rotatingMode = false;
  checkDrag = false;
  //check to see if user clicked middle of screen within 3 inches
}


//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex);  
  boolean closeDist = dist(t.x, t.y, screenTransX, screenTransY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation, screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchToPix(.05f); //has to be within +-0.05"  

  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + screenTransX + "/" + screenTransY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation, screenRotation)+")");
  println("Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
