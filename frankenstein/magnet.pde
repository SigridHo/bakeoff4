import ketai.sensors.*;

KetaiSensor sensor;

double fieldStrength = 0;
double linearized = 0;
double[] thresholds = {36.0, 55.0, 60.0, 82.0, 90.0, 115.0, 124.0, 150.0};

final double K = 1000.0;
final boolean DEBUG_MAGNET = false;

void setupMagnet()
{
  sensor = new KetaiSensor(this);
  sensor.start();
}

int classifyMagnet()
{
  double l = linearized;
  if (Double.isNaN(l))
    return -1;
  for (int i = 0; i < 4; i++)
  {
    if (thresholds[2 * i] < l && l < thresholds[2 * i + 1])
      return i;
  }
  return -1;
}

void onMagneticFieldEvent(float x, float y, float z)
{
  fieldStrength = Math.sqrt(x * x + y * y + z * z);
  linearized = K / Math.sqrt(fieldStrength);
  debugMagnet("Linearized: " + Double.toString(linearized));
  if (startTime == 0 && linearized < 100.0)
  {
    startTime = millis();
    magnetPhaseBegin = millis();
  }
}

void debugMagnet(String s)
{
  if (DEBUG_MAGNET)
    System.out.println(s);
}

