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
int currentFirst = -1;
int secondChoice = -1;
//boolean start = false;
boolean firstSet = false;
boolean up = false;
PVector rotations, rotationStandard;
String[] instr = {"forward", "back"};
int tiltCount = 0;

void setup() {
  size(500, 900, OPENGL); //you can change this to be fullscreen
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(PORTRAIT);

  rectMode(CENTER);
  //textFont(createFont("Arial", 20)); //sets the font to Arial size 20
  textSize(20);
  textAlign(CENTER);
  rotations = new PVector();
  rotationStandard = new PVector();
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
  text("Target #" + ((targets.get(index).target)+1) + ".", width/2, 100);
  //if(up) 
  text("Action " + ((targets.get(index).action)+1) + ". Lean " + instr[targets.get(index).action], width/2, 150);
  pushMatrix();
  translate(width - 50, height/2);
  rotate(HALF_PI);
  text("Action " + ((targets.get(index).action)+1) + ". Lean " + instr[targets.get(index).action], 0,0);
  popMatrix();
  pushMatrix();
  translate(width/2, height - 200);
  rotate(PI);
  text("Action " + ((targets.get(index).action)+1) + ". Lean " + instr[targets.get(index).action], 0,0);
  popMatrix();
  pushMatrix();
  translate(50, height/2);
  rotate(-HALF_PI);
  text("Action " + ((targets.get(index).action)+1) + ". Lean " + instr[targets.get(index).action], 0,0);
  popMatrix();

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
      if (firstSet) {
        fill(255,0,0);
      }
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
/*
void onOrientationEvent(float x, float y, float z) {
  int index = trialIndex;

  if (userDone || index>=targets.size())
    return;
  Target t = targets.get(index);
  if (t==null)
    return;
  rotations.set(x, y, z);
  if (!firstSet) return;
  //if (firstSet && up) {
  if(firstSet) {
    if (firstChoice == 0) {
      if (y < -100) {
        secondChoice = 0;
      } 
      if (y > -50) {
        secondChoice = 1;
      }
    } else if (firstChoice == 1) {
      if (z > 80) {
        secondChoice = 0;
      } else if (z < 40) {
        secondChoice = 1;
      }
    } else if (firstChoice == 2) {
      if (y > 100) {
        secondChoice = 0;
      } else if (y < 50) {
        secondChoice = 1;
      }
    } else {
      if (z < -80) {
        secondChoice = 0;
      } else if (z > -40) {
        secondChoice = 1;
      }
    }
    //float minBound = (rotationStandard.x - 30 + 360) % 360;
    //float maxBound = (rotationStandard.x + 30) % 360;
    //println("##################");
    //println(rotationStandard.x);
    //println("&&&&&&&&&&&&&&&&&&&&&&&");
    //println(x);
    //println("$$$$$$$$$$$$$$$$$");
    //if (rotationStandard.x >= 60 && rotationStandard.x <= 300) {
    //  if (x > rotationStandard.x - 60 && x < rotationStandard.x - 30) {
    //    secondChoice = 0;
    //  } else if (x > rotationStandard.x + 30 && x < rotationStandard.x + 60) {
    //    secondChoice = 1;
    //  }
    //} else if (rotationStandard.x < 60) {
    //  if (rotationStandard.x >= 30) {
    //    if ((x > rotationStandard.x + 300) || (x < rotationStandard.x - 30)) {
    //      secondChoice = 0;
    //    } else if ((x > rotationStandard.x + 30) && (x < rotationStandard.x + 60)) {
    //      secondChoice = 1;
    //    }
    //  } else {
    //    if (x > rotationStandard.x + 300 && x < rotationStandard.x + 330) {
    //      secondChoice = 0;
    //    } else if ((x > rotationStandard.x + 30) && (x < rotationStandard.x + 60)) {
    //      secondChoice = 1;
    //    }
    //  }
    //} else {
    //  if (rotationStandard.x >= 330) {
        //if (x > rotationStandard.x - 60 && x < rotationStandard.x - 30) {
        //  secondChoice = 0;
        //} else if ((x > (rotationStandard.x + 30) % 360) && (x < (rotationStandard.x + 60) % 360)) {
        //  secondChoice = 1;
        //}
     // } else {
        //if (x > rotationStandard.x - 60 && x < rotationStandard.x - 30) {
        //  secondChoice = 0;
        //} else if ((x > rotationStandard.x + 30) || (x < (rotationStandard.x + 60) % 360)) {
        //  secondChoice = 1;
        //}
      //}
//    }
//    
    if (secondChoice != -1 && countDownTimerWait < 0) {
      if (firstChoice == t.target && secondChoice == t.action) {
        println("Right target, right action!");
        trialIndex++; //next trial!
        //start = false;
        firstSet = false;
        up = false;
        firstChoice = -1;
        currentFirst = -1;
        secondChoice = -1;
        countDownTimerWait=30;
      } else {
        if (firstChoice != t.target)
          println("Wrong target!" + firstChoice);
        if (secondChoice != t.action) 
          println("Wrong action!" + secondChoice);
        if (trialIndex>0) {
          trialIndex--; //move back one trial as penalty!
          //start = false;
        }       
        firstSet = false;
        up = false;
        firstChoice = -1;
        currentFirst = -1;
        secondChoice = -1;
        countDownTimerWait=30;
      }
    }
    
  }
}
*/
//void onProximityEvent(float d) {
//  int index = trialIndex;
//  if (userDone || index>=targets.size())
//    return;
//  Target t = targets.get(index);
//  if (t==null)
//    return;
//  //if (!start || firstChoice == -1) return;
//  if (!firstSet) return;
//  if (d < 0.1 && !firstSet) {
//    println("!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//    firstSet = true;
////    rotationStandard.set(rotations);
//  }
//}


void onAccelerometerEvent(float x, float y, float z)
{
  int index = trialIndex;

  if (userDone || index>=targets.size())
    return;
  Target t = targets.get(index);
  if (t==null)
    return;

  //if (start && !firstSet) {
    if (!firstSet) {
    boolean flag = true;
    if (y > 7) {
      firstChoice = 0;
    } else if (y < -7) {
      firstChoice = 2;
    } else if (x > 7) {
      firstChoice = 1;
    } else if (x < -7){
      firstChoice = 3;
    }  else {
      flag = false;
    }
    if (countDownTimerWait > 0) return;
    if (flag && countDownTimerWait < 0) {
      if (firstChoice != currentFirst) {
        currentFirst = firstChoice;
        tiltCount = millis();
      } else {
        int currentTime = millis();
        if (currentTime > tiltCount + 500) {
          firstSet = true;
        }
      }
    }
  //} else if (!firstSet) {
    //if (x > -2 && x < 2 && y > -2 && y < 2) {
    //  start = true;
    //} 
  } else {
    if (z > 8) {
      secondChoice = 1;
    } else if (z < 0) {
      secondChoice = 0;
    }
  }
  if (secondChoice != -1 && countDownTimerWait < 0) {
      if (firstChoice == t.target && secondChoice == t.action) {
        println("Right target, right action!");
        trialIndex++; //next trial!
        //start = false;
        firstSet = false;
        up = false;
        firstChoice = -1;
        currentFirst = -1;
        secondChoice = -1;
        countDownTimerWait=30;
      } else {
        if (firstChoice != t.target)
          println("Wrong target!" + firstChoice);
        if (secondChoice != t.action) 
          println("Wrong action!" + secondChoice);
        if (trialIndex>0) {
          trialIndex--; //move back one trial as penalty!
          //start = false;
        }       
        firstSet = false;
        up = false;
        firstChoice = -1;
        currentFirst = -1;
        secondChoice = -1;
        countDownTimerWait=30;
      }
    }
  //if (light>proxSensorThreshold) //only update cursor, if light is low
  //{
  //  cursorX = 300+x*40; //cented to window and scaled
  //  cursorY = 300-y*40; //cented to window and scaled
  //}

  
 
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