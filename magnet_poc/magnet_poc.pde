import ketai.sensors.*;

KetaiSensor sensor;


void setup()
{
  orientation(PORTRAIT);
  size(1080, 1920);
  fill(1);
  sensor = new KetaiSensor(this);
  sensor.start();
  sensor.list();
  textSize(64);
  calibrate();
}


int level = 0;
// int lastChange = 0;
// final int DELAY = 250;
//
// float light;
//
// boolean lagLightLevelHigh = true;
// int lastTapTime = 0;
// final float LIGHT_LOGIC_HIGH = 30;
// final float LIGHT_LOGIC_LOW = 20;
double backgroundField = 0;

void calibrate()
{
  double acc = 0;
  for (int i = 0; i < 100; i++)
  {
    acc += uT;
    delay(10);
  }
  backgroundField = acc / 100.0;
}

void draw()
{
  background(0xFFFFFFFF);
  // int newLevel = teslasToLevel(newScaled);
  fill(0xFF000000);

  text("Raw: " + Double.toString(uT), 100, 100);

  double newScaled = 1000.0 / Math.sqrt(uT - backgroundField);
  text("Inverse sqrt: " + Double.toString(newScaled), 100, 200);

}

// obsolete - not accurate
// int teslasToLevel(double scaled)
// {
//   if (scaled < 12.5)
//     return 1;
//   else if (scaled < 15.5)
//     return 2;
//   else if (scaled < 22)
//     return 3;
//   else
//     return 4;
// }
boolean started = false;

double uT = 0;

void onMagneticFieldEvent(float x, float y, float z)
{
  uT = Math.sqrt(x * x + y * y + z * z);
}

  // int curMillis = millis();
  // if (newLevel != level)
  // {
  //   lastChange = curMillis;
  //   level = newLevel;
  // }
  // else
  // {
  //   if (curMillis - lastChange > 250)
  //   {
  //     // System.out.println(level);
  //     lastChange = millis();
  //   }
  // }

  // text(Float.toString(light), 100, 300);

  // if (light > LIGHT_LOGIC_HIGH)
  // {
  //   lagLightLevelHigh = true;
  // }
  // else if (light < LIGHT_LOGIC_LOW)
  // {
  //   if (lagLightLevelHigh)
  //     System.out.println("Tapped!");
  //   lagLightLevelHigh = false;
  // }
// void onLightEvent(float v) //this just updates the light value
// {
//   light = v;
// }
