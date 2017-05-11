import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
float light = 0; 
float proxSensorThreshold = 20; //you will need to change this per your device.

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;
static float rectSize = 100; 
float[] center = {250, 450};
float[] rectX = {250, 350, 250, 150};
float[] rectY = {350, 450, 550, 450};
int firstChoice = -1;
void setup() {
  size(500, 900); //you can change this to be fullscreen
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(PORTRAIT);

  rectMode(CENTER);
  //textFont(createFont("Arial", 20)); //sets the font to Arial size 20
  textSize(20);
  textAlign(CENTER);

  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey
  noStroke(); //no stroke

  countDownTimerWait--;

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 1) + " sec per target", width/2, 150);
    return;
  }

  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  text("Target #" + (targets.get(index).target)+1, width/2, 100);

  //if (targets.get(index).action==0)
  //  text("UP", width/2, 150);
  //else
  //  text("DOWN", width/2, 150);
    
  for (int i=0; i<4; i++)
  {
    if (targets.get(index).target==i)
      fill(0, 255, 0);
    else
      fill(180, 180, 180);
    //ellipse(300, i*150+100, 100, 100);
    if (i == firstChoice) {
      stroke(255,0,0);
      strokeWeight(10);
    }
     rect(rectX[i], rectY[i], 100, 100);
     fill(0);
     strokeWeight(1);
     noStroke();
     switch(i) {
       case 0:
         drawArrow(rectX[i], rectY[i]+30, rectX[i], rectY[i]-30);
         break;
       case 1:
         drawArrow(rectX[i]-30, rectY[i], rectX[i]+30, rectY[i]);
         break;
       case 2:
         drawArrow(rectX[i], rectY[i]-30, rectX[i], rectY[i]+30);
         break;
       case 3:
         drawArrow(rectX[i]+30, rectY[i], rectX[i]-30, rectY[i]);
         break;
     }
  }

  //if (light>proxSensorThreshold)
  //  fill(180, 0, 0);
  //else
  //  fill(255, 0, 0);
  //ellipse(cursorX, cursorY, 50, 50);

  
}

void onAccelerometerEvent(float x, float y, float z)
{
  if (y > 7) {
    firstChoice = 0;
  } else if (y < -7) {
    firstChoice = 2;
  } else if (x > 7) {
    firstChoice = 1;
  } else if (x < -7){
    firstChoice = 3;
  }
  //println(x);
  //println(y);
  //println(z);
  //println("**********");
  //int index = trialIndex;

  //if (userDone || index>=targets.size())
  //  return;

  //if (light>proxSensorThreshold) //only update cursor, if light is low
  //{
  //  cursorX = 300+x*40; //cented to window and scaled
  //  cursorY = 300-y*40; //cented to window and scaled
  //}

  //Target t = targets.get(index);

  //if (t==null)
  //  return;
 
  //if (light<=proxSensorThreshold && abs(z-9.8)>4 && countDownTimerWait<0) //possible hit event
  //{
  //  if (hitTest()==t.target)//check if it is the right target
  //  {
  //    //println(z-9.8); use this to check z output!
  //    if (((z-9.8)>4 && t.action==0) || ((z-9.8)<-4 && t.action==1))
  //    {
  //      println("Right target, right z direction!");
  //      trialIndex++; //next trial!
  //    } else
  //    {
  //      if (trialIndex>0)
  //        trialIndex--; //move back one trial as penalty!
  //      println("right target, WRONG z direction!");
  //    }
  //    countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
  //  } 
  //} else if (light<=proxSensorThreshold && countDownTimerWait<0 && hitTest()!=t.target)
  //{ 
  //  println("wrong round 1 action!"); 

  //  if (trialIndex>0)
  //    trialIndex--; //move back one trial as penalty!

  //  countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
  //}
}

//int hitTest() 
//{
//  for (int i=0; i<4; i++)
//    if (dist(300, i*150+100, cursorX, cursorY)<100)
//      return i;

//  return -1;
//}


//void onLightEvent(float v) //this just updates the light value
//{
//  light = v;
//}

void drawArrow(float x1, float y1, float x2, float y2) {
  float a = dist(x1, y1, x2, y2)/10;
  pushMatrix();
  translate(x2, y2);
  rotate(atan2(y2 - y1, x2 - x1));
  triangle(- a * 2 , - a, 0, 0, - a * 2, a);
  popMatrix();
  stroke(0);
  line(x1, y1, x2, y2);
  noStroke();
}