import ketai.sensors.*;

KetaiSensor sensor;
float accelerometerX, accelerometerY, accelerometerZ;

void setup()
{
  size(500, 900);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(PORTRAIT);
  textAlign(CENTER, CENTER);
  textSize(20);
}

void draw()
{
  
  background(78, 93, 75);
  text("Accelerometer: \n" + 
    "x: " + nfp(accelerometerX, 1, 3) + "\n" +
    "y: " + nfp(accelerometerY, 1, 3) + "\n" +
    "z: " + nfp(accelerometerZ, 1, 3), 0, 0, width, height);
   
}

void onAccelerometerEvent(float x, float y, float z)
{
  accelerometerX = x;
  accelerometerY = y;
  accelerometerZ = z;
}