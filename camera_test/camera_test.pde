import ketai.camera.*;

KetaiCamera cam;

void setup() {
  size(1080, 1920);
  orientation(PORTRAIT);
  cam = new KetaiCamera(this, 1440, 1080, 24);
  cam.setCameraID(1);
  cam.manualSettings();
  strokeWeight(4);
}

final int x_sample = 540;
final int y_sample = 720;
final int reticle_length = 40;
void draw()
{
  background(0);
  pushMatrix();
  rotate(-PI / 2);
  scale(1.0, -1.0);
  image(cam, -1440, -1080);
  popMatrix();
  color c = cam.get(y_sample, x_sample);
  line(x_sample - reticle_length, y_sample, x_sample + reticle_length, y_sample);
  line(x_sample, y_sample - reticle_length, x_sample, y_sample + reticle_length);
  System.out.println("Red: " + Float.toString(red(c)) +
                     " Green: " + Float.toString(green(c)) +
                     " Blue: " + Float.toString(blue(c)));
  System.out.println(colorShrink(c));
}

boolean started = false;
boolean toggle = false;

void onCameraPreviewEvent()
{
  cam.read();
}

void mousePressed()
{
  if (!started)
  {
    cam.start();
    started = true;
  }
  toggle = !toggle;
}

public enum Color { RED, GREEN, OTHER };

Color colorShrink(color c)
{
  if (red(c) + green(c) + blue(c) < 100.0)
    return Color.OTHER;
  else if (red(c) / (green(c) + blue(c)) > 0.8)
    return Color.RED;
  else if (green(c) / red(c) > 1.4)
    return Color.GREEN;
  else
    return Color.OTHER;
}

