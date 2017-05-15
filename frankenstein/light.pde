float light = 0;
final float LIGHT_LOGIC_HIGH = 13;
final float LIGHT_LOGIC_LOW = 8;
final boolean DEBUG_LIGHT = false;
LightState ls = LightState.HIGH;

public enum LightState { HIGH, LOW }

void onLightEvent(float v) //this just updates the light value
{
  light = v;
  if (v < LIGHT_LOGIC_LOW)
    ls = LightState.LOW;
  else if (v > LIGHT_LOGIC_HIGH)
    ls = LightState.HIGH;
  debugLight(ls.toString());
}

void debugLight(String s)
{
  if (DEBUG_LIGHT)
    System.out.println(s);
}
