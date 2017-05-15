import java.util.ArrayList;
import java.util.Collections;

final int TRIAL_COUNT = 5; // This will be set higher for the bakeoff
final boolean DEBUG = true;
final int MAGNET_LOCKIN_MILLIS = 2500;
final int LOCKOUT_DELAY_MILLIS = 500;

final int BACKGROUND_COLOR = 0xFF000000; // Black
final int TEXT_COLOR = 0xFFFFFFFF; // White
final int PROGRESS_BAR_FILLING = 0xFF296DDB; // Blue
final int PROGRESS_BAR_EMPTY = 0xFFFFFFFF; // White

int trialIndex = 0;
ArrayList<Target> targets;

// Phase state
int magnetLastEdgeTime = 0;
int magnetLastValue = -1; // Start off magnet at an invalid value
Color colorLastValue = Color.OTHER;
Phase currentPhase = Phase.FROM_FOUR;

int lockoutUntil = 0;
int startTime = 0; // Time starts when the first click is captured
int finishTime = 0; // Records the time of the final click

public enum Phase { FROM_FOUR, FROM_TWO };

private class Target
{
  int target = 0;
  int action = 0;
}

void setup()
{
  size(1080, 1920);
  orientation(PORTRAIT);
  textSize(60);

  setupCamera();

  setupMagnet();

  resetState();
}

void resetState()
{
  trialIndex = 0;
  startTime = 0;
  finishTime = 0;
  lockoutUntil = 0;
  resetTrialState();

  targets = new ArrayList<Target>();
  // Don't change this!
  for (int i = 0; i < TRIAL_COUNT; i++)
  {
    Target t = new Target();
    t.target = ((int)random(1000)) % 4;
    t.action = ((int)random(1000)) % 2;
    targets.add(t);
    System.out.println("Created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets);
  calibrateMagnet();
}

void resetTrialState()
{
  magnetLastValue = -1; // Start off magnet at an invalid value
  colorLastValue = Color.OTHER;
  currentPhase = Phase.FROM_FOUR;
}

void draw()
{
  if (startTime == 0)
    startTime = millis();
  else if (trialIndex >= TRIAL_COUNT)
  {
    if (finishTime == 0)
      finishTime = millis();

    text("User completed " + TRIAL_COUNT + " trials", width / 2, 50);
    text("User took " + nfc((finishTime - startTime) / 1000f / TRIAL_COUNT,
                            1) + " sec per target", width / 2, 150);
  }
  else
  {
    background(0);
    drawPreview();

    fill(TEXT_COLOR);
    text("Trial " + (trialIndex + 1) + " of " + TRIAL_COUNT, 100, 1500);

    if (currentPhase == Phase.FROM_FOUR)
    {
      text("Target #" + Integer.toString((targets.get(trialIndex).target) + 1),
           100, 1575);

      int currentMagnetValue = classifyMagnet();
      int currTime = millis();
      if (currentMagnetValue == magnetLastValue)
      {
        if (currTime - magnetLastEdgeTime > MAGNET_LOCKIN_MILLIS)
        {
          currentPhase = Phase.FROM_TWO;
        }
      }
      else // Magnet value changed
      {
        magnetLastValue = currentMagnetValue;
        magnetLastEdgeTime = currTime;
      }

      text("Currently Selected: " + Integer.toString(currentMagnetValue + 1), 100, 1650);

      // Draw progress bar empty
      noStroke();
      fill(PROGRESS_BAR_EMPTY);
      rect(100, 1700, 880, 75);
      // Draw progress bar filling
      fill(PROGRESS_BAR_FILLING);
      double percentFull = (currTime - magnetLastEdgeTime) / (double) MAGNET_LOCKIN_MILLIS;
      rect(100, 1700, Math.min((int) Math.round(percentFull * 880), 880), 75);
    }
    else // currentPhase == Phase.FROM_TWO
    {
      text("Target Color: ", 100, 1575);
      // Draw color
      fill(actionToColor(targets.get(trialIndex).action).hex);
      rect(500, 1500, 300, 75);

      if (currColor == Color.DARK)
      {
        // TODO: Print debug info here
        // Correct
        if (colorLastValue == actionToColor(targets.get(trialIndex).action) &&
            targets.get(trialIndex).target == magnetLastValue)
        {
          trialIndex++;
          resetTrialState();
        }
        // Wrong
        else
          penalize();
      }
      else
        colorLastValue = currColor;

      fill(TEXT_COLOR);
      text("Current Color: ", 100, 1650);
      fill(currColor.hex);
      rect(500, 1575, 300, 90);
    }
  }
}

void penalize()
{
  if (trialIndex > 0)
    trialIndex--;
  resetTrialState();
  lockoutUntil = millis() + 500;
}

void debug(String s)
{
  if (DEBUG)
    System.out.println(s);
}

void mousePressed()
{
  if (!cameraStarted)
  {
    cam.start();
    cameraStarted = true;
  }
}
