import ketai.sensors.*;

KetaiSensor sensor;

double fieldStrength = 0;
double backgroundFieldStrength = 0;
double linearized = 0;

final double K = 1000.0;
final boolean DEBUG_MAGNET = false;

void setupMagnet()
{
  sensor = new KetaiSensor(this);
  sensor.start();
  calibrateMagnet();
}

void calibrateMagnet()
{
  double acc = 0;
  for (int i = 0; i < 100; i++)
  {
    acc += fieldStrength;
    delay(10);
  }
  backgroundFieldStrength = acc / 100.0;
}

int classifyMagnet()
{
  if (linearized < 55)
    return 0;
  else if (linearized < 90)
    return 1;
  else if (linearized < 150)
    return 2;
  else
    return 3;
}

void onMagneticFieldEvent(float x, float y, float z)
{
  fieldStrength = Math.sqrt(x * x + y * y + z * z);
  linearized = K / Math.sqrt(fieldStrength - backgroundFieldStrength);
  debugMagnet("Linearized: " + Double.toString(linearized));
  if (!cameraStarted && classifyMagnet() == 0)
  {
    cam.start();
    cameraStarted = true;
  }
}

void debugMagnet(String s)
{
  if (DEBUG_MAGNET)
    System.out.println(s);
}

