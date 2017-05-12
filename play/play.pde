import ketai.sensors.*;

KetaiSensor sensor;
float rotationX, rotationY, rotationZ;

void setup()
{
  size(500, 900, OPENGL);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(PORTRAIT);
  textAlign(CENTER, CENTER);
  textSize(20);
  
}

void draw()
{
  background(78, 93, 75);
  text("Gyroscope: \n" + 
    "x: " + nfp(rotationX, 1, 3) + "\n" +
    "y: " + nfp(rotationY, 1, 3) + "\n" +
    "z: " + nfp(rotationZ, 1, 3), 0, 0, width, height);
}

void onRotationVectorEvent(float x, float y, float z)
{ 
  println(x);
  println(y);
  println(z);
  println("$$$$$$$$");
  rotationX = x;
  rotationY = y;
  rotationZ = z;
}