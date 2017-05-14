import ketai.camera.*;

KetaiCamera cam;

void setupCamera()
{
  cam = new KetaiCamera(this, 1440, 1080, 24);
  cam.setCameraID(1);
  cam.manualSettings();
}

final int X_SAMPLE = 540;
final int Y_SAMPLE = 720;
final int RETICLE_LENGTH = 40;

color c;

void drawPreview()
{
  background(0);
  pushMatrix();
  rotate(-PI / 2);
  scale(1.0, -1.0);
  image(cam, -1440, -1080);
  popMatrix();
  line(X_SAMPLE - RETICLE_LENGTH, Y_SAMPLE, X_SAMPLE + RETICLE_LENGTH, Y_SAMPLE);
  line(X_SAMPLE, Y_SAMPLE - RETICLE_LENGTH, X_SAMPLE, Y_SAMPLE + RETICLE_LENGTH);


}

void onCameraPreviewEvent()
{
  cam.read();
  c = cam.get(Y_SAMPLE, X_SAMPLE);
  System.out.println("Red: " + Float.toString(red(c)) +
                     " Green: " + Float.toString(green(c)) +
                     " Blue: " + Float.toString(blue(c)) +
                     System.lineSeparator() +
                     classifyColor(c));
}

public enum Color { RED, GREEN, DARK, OTHER };

Color classifyColor(color c)
{
  if (red(c) + green(c) + blue(c) < 80.0)
    return Color.DARK;
  else if (red(c) / (green(c) + blue(c)) > 0.8)
    return Color.RED;
  else if (green(c) / red(c) > 1.4)
    return Color.GREEN;
  else
    return Color.OTHER;
}
