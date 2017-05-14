import ketai.sensors.*;

KetaiSensor sensor;

double fieldStrength = 0;
double backgroundFieldStrength = 0;
double linearized = 0;

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
    acc += uT;
    delay(10);
  }
  backgroundField = acc / 100.0;
}

final double K = 1000.0;

void onMagneticFieldEvent(float x, float y, float z)
{
  fieldStrength = Math.sqrt(x * x + y * y + z * z);
  linearized = K / Math.sqrt(fieldStrength - backgroundFieldStrength);
}
