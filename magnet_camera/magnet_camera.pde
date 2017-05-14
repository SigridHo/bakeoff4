import java.util.ArrayList;
import java.util.Collections;

private class Target
{
  int target = 0;
  int action = 0;
}

final int TRIAL_COUNT = 5; // This will be set higher for the bakeoff
final boolean DEBUG = false;

int trialIndex = 0;
ArrayList<Target> targets;

int startTime = 0; // Time starts when the first click is captured
int finishTime = 0; // Records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;

void setup()
{
  size(1080, 1920);
  orientation(PORTRAIT);
  strokeWeight(4);
  rectMode(CENTER);
  textFont(createFont("Arial", 20));
  textAlign(CENTER);

  setupCamera();

  setupMagnet();

  resetState();
}

void resetState()
{
  trialIndex = 0;
  startTime = 0;
  finishTime = 0;
  userDone = false;
  targets = new ArrayList<Target>();

  // Don't change this!
  for (int i=0; i<TRIAL_COUNT; i++)
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("Created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets);
}


void draw()
{
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey


  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + TRIAL_COUNT + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/TRIAL_COUNT, 1) + " sec per target", width/2, 150);
    return;
  }

  for (int i=0; i<4; i++)
  {
    if (targets.get(index).target==i)
      fill(0, 255, 0);
    else
      fill(180, 180, 180);
    ellipse(300, i*150+100, 100, 100);
  }

  if (light>proxSensorThreshold)
    fill(180, 0, 0);
  else
    fill(255, 0, 0);
  ellipse(cursorX, cursorY, 50, 50);

  fill(255);//white
  text("Trial " + (index+1) + " of " +TRIAL_COUNT, width/2, 50);
  text("Target #" + (targets.get(index).target)+1, width/2, 100);

  if (targets.get(index).action==0)
    text("UP", width/2, 150);
  else
    text("DOWN", width/2, 150);
}

