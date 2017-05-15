import ketai.camera.*;

KetaiCamera cam;
Color currColor = Color.OTHER;

final int X_SAMPLE = 540;
final int Y_SAMPLE = 720;
final int RETICLE_LENGTH = 40;
final boolean DEBUG_CAMERA = false;

public enum Color
{
  RED (0xFFFF0000),
  GREEN(0xFF00FF00),
  OTHER(0xFF808080);

  public final int hex;

  Color(int hex)
  {
    this.hex = hex;
  }
}

void setupCamera()
{
  cam = new KetaiCamera(this, 1440, 1080, 24);
  cam.setCameraID(1);
  cam.manualSettings();
}

void drawPreview()
{
  pushMatrix();
  rotate(-PI / 2);
  scale(1.0, -1.0);
  image(cam, -1440, -1080);
  popMatrix();
  stroke(BACKGROUND_COLOR);
  strokeWeight(4);
  line(X_SAMPLE - RETICLE_LENGTH, Y_SAMPLE, X_SAMPLE + RETICLE_LENGTH, Y_SAMPLE);
  line(X_SAMPLE, Y_SAMPLE - RETICLE_LENGTH, X_SAMPLE, Y_SAMPLE + RETICLE_LENGTH);
  noStroke();
}

void onCameraPreviewEvent()
{
  cam.read();
  color c = cam.get(Y_SAMPLE, X_SAMPLE);
  Color newColor = classifyColor(c);
  currColor = newColor == Color.OTHER ? currColor : newColor;
  debugCamera("Red: " + Float.toString(red(c)) +
              " Green: " + Float.toString(green(c)) +
              " Blue: " + Float.toString(blue(c)) +
              System.lineSeparator() +
              newColor);
}

Color classifyColor(color c)
{
  if (red(c) + green(c) + blue(c) < 80.0)
    return Color.OTHER;
  else if (red(c) / (green(c) + blue(c)) > 0.8)
    return Color.RED;
  else if (green(c) / red(c) > 1.4)
    return Color.GREEN;
  else
    return Color.OTHER;
}

Color actionToColor(int action)
{
  if (action == 0)
    return Color.GREEN;
  else
    return Color.RED;
}

void debugCamera(String s)
{
  if (DEBUG_CAMERA)
    System.out.println(s);
}
