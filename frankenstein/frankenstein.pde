import java.util.ArrayList;
import java.util.Collections;

final int TRIAL_COUNT = 20; // This will be set higher for the bakeoff
final boolean DEBUG = true;
final int MAGNET_LOCKIN_MILLIS = 250;
final int MAGNET_INIT_DELAY_MILLIS = 825;
final int LOCKOUT_DELAY_MILLIS = 500;

final int BACKGROUND_COLOR = 0xFF000000; // Black
final int TEXT_COLOR = 0xFFFFFFFF; // White
final int PROGRESS_BAR_FILLING = 0xFF296DDB; // Blue
final int PROGRESS_BAR_EMPTY = 0xFFFFFFFF; // White


// Trial state
int magnetLastEdgeTime = 0;
int magnetLastValue = -1; // Start off magnet at an invalid value
int magnetPhaseBegin = 0;
Phase currentPhase = Phase.FROM_FOUR;

ArrayList<Target> targets;
int trialIndex = 0;
int lockoutUntil = 0;
int resetTapCount = 0;
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

  trialIndex = 0;
  lockoutUntil = 0;
  resetTapCount = 0;
  startTime = 0;
  finishTime = 0;
  resetTrialState();
}

void resetTrialState()
{
  magnetLastValue = -2; // Start off magnet at an invalid value
  magnetPhaseBegin = millis();
  currentPhase = Phase.FROM_FOUR;
}

void draw()
{
  background(BACKGROUND_COLOR);
  drawPreview();
  if (startTime == 0)
  {
    fill(TEXT_COLOR);
    text("Move magnet close to begin.", 50, 1500);
  }
  else if (trialIndex >= TRIAL_COUNT)
  {
    if (finishTime == 0)
      finishTime = millis();

    fill(TEXT_COLOR);
    text("User completed " + TRIAL_COUNT + " trials", 100, 1500);
    text("User took " + nfc((finishTime - startTime) / 1000f / TRIAL_COUNT,
                            1) + " sec per target", 100, 1575);
  }
  else
  {
    fill(TEXT_COLOR);
    text("Trial " + (trialIndex + 1) + " of " + TRIAL_COUNT, 100, 1500);

    if (currentPhase == Phase.FROM_FOUR)
    {
      text("Target #" + Integer.toString((targets.get(trialIndex).target) + 1),
           100, 1575);

      int currentMagnetValue = classifyMagnet();
      int currTime = millis();

      if (millis() > lockoutUntil)
      {
        if (currentMagnetValue == magnetLastValue && currentMagnetValue >= 0)
        {
          if (currTime - Math.max(magnetLastEdgeTime,
                                  magnetPhaseBegin + MAGNET_INIT_DELAY_MILLIS)
              > MAGNET_LOCKIN_MILLIS)
          {
            currentPhase = Phase.FROM_TWO;
          }
        }
        else // Magnet value changed or is invalid
        {
          magnetLastValue = currentMagnetValue;
          magnetLastEdgeTime = currTime;
        }
      }

      // Indicator bar
      fill(0xFFDADFE1);
      rect(880, 200, 100, 900);

      int i = targets.get(trialIndex).target;
      fill(0xFFFF0000);
      // Fill location
      rect(880, (int) Math.round(1100 - thresholds[2 * i + 1] * 6),
           100, (int) Math.round((thresholds[2 * i + 1] - thresholds[2 * i]) * 6));

      strokeWeight(8);
      stroke(0xFF000000);
      int height = (int) Math.round(1100 - linearized * 6);
      line(880, height, 980, height);

      fill(TEXT_COLOR);
      text("Currently Selected: " +
           (currentMagnetValue >= 0 ?
            Integer.toString(currentMagnetValue + 1) : "None"),
           100, 1650);

      // Draw progress bar empty
      noStroke();
      fill(PROGRESS_BAR_EMPTY);
      rect(100, 1700, 880, 75);
      // Draw progress bar filling
      fill(PROGRESS_BAR_FILLING);
      double percentFull = Math.max(0, currTime - Math.max(magnetLastEdgeTime,
                                    magnetPhaseBegin + MAGNET_INIT_DELAY_MILLIS)) / (double) MAGNET_LOCKIN_MILLIS;
      rect(100, 1700, Math.min((int) Math.round(percentFull * 880), 880), 75);
    }
    else // currentPhase == Phase.FROM_TWO
    {
      text("Target Color: ", 100, 1575);
      // Draw color
      fill(actionToColor(targets.get(trialIndex).action).hex);
      rect(500, 1500, 300, 75);

      if (millis() > lockoutUntil)
      {
        if (ls == LightState.LOW)
        {
          Color correctColor = actionToColor(targets.get(trialIndex).action);
          int correctTarget = targets.get(trialIndex).target;
          debug("Current color: " + currColor + " Correct color: " + correctColor);
          debug("Current target: " + magnetLastValue +
                "Correct target: " + correctTarget);
          // TODO: Print debug info here
          // Correct
          if (currColor == correctColor && correctTarget == magnetLastValue)
          {
            debug("CORRECT!");
            trialIndex++;
            resetTrialState();
          }
          // Wrong
          else
          {
            debug("WRONG :(");
            penalize();
          }
        }
      }

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
  /* This is a massive hack.  This is necessary because cam.start()
   * does not appear to be able to be called within a draw() or setup()
   * call() */
  if (mouseY < 1440)
  {
    cam.start();
  }
  else
  {
    debug("Incrementing reset counter!");
    resetTapCount++;
    if (resetTapCount == 5)
    {
      debug("Resetting state!");
      resetState();
    }
  }
}
