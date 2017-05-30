#include <Servo.h>

String val;
int Pin1 = 11;
int Pin2 = 9;
int Pin3 = 7;
int Pin4 = 5;
int Pin5 = 3;
int Pin6 = 2;

Servo servo1, servo2, servo3, servo4, servo5, servo6;
bool minPos1 = false, minPos2 = false, minPos3 = false, 
      minPos4 = false, minPos5 = false, minPos6 = false;

int pos1 = 0;

float up_speed, down_speed;
String MovingSpeed;

int max_pos = 165;
int min_pos = 25;

void setup() {
  
  pinMode(Pin1, OUTPUT); //set pin as output
  pinMode(Pin2, OUTPUT);
  pinMode(Pin3, OUTPUT);
  pinMode(Pin4, OUTPUT);
  pinMode(Pin5, OUTPUT);
  pinMode(Pin6, OUTPUT);
  
  Serial.begin(115200);
  //Console.begin();
  //Console.println("All set");
  //Serial.print("All set\n");

  servo1.attach(Pin1);
  servo2.attach(Pin2);
  servo3.attach(Pin3);
  servo4.attach(Pin4);
  servo5.attach(Pin5);
  servo6.attach(Pin6);

  up_speed = 0;
  down_speed = 0;

}

void loop() {

  if(Serial.available() > 0)
  {
    //Serial.println("ready");
    
    val = Serial.readStringUntil('\n');
    //val = Serial.read();
    val.trim();
    //Serial.println(val);
    //Console.println(val);

    MovingSpeed = val.substring(11);
    //val = Serial.readStringUntil('_');
    val = val.substring(0, 10);
    
    //up_speed = sub.toFloat();
    //Serial.print(val);
  }

  if(val == "moveToMax1")
  {
    up_speed = MovingSpeed.toFloat();
    if(minPos1)
      moveToMax(servo1, minPos1);
  }
  else if (val == "moveToMin1")
  {
    down_speed = MovingSpeed.toFloat();
    if(!minPos1)
      moveToMin(servo1, minPos1);
  }

  else if (val == "moveToMax2")
  {
    up_speed = MovingSpeed.toFloat();
    //Serial.print(minPos2);
    if(minPos2)
      moveToMax(servo2, minPos2);
    //Serial.print(minPos2);
  }
  else if (val == "moveToMin2")
  {
    down_speed = MovingSpeed.toFloat();
    if(!minPos2)
      moveToMin(servo2, minPos2);
  }

  else if (val == "moveToMax3")
  {
    up_speed = MovingSpeed.toFloat();
    //Serial.print(minPos2);
    if(minPos3)
      moveToMax(servo3, minPos3);
    //Serial.print(minPos2);
  }
  else if (val == "moveToMin3")
  {
    down_speed = MovingSpeed.toFloat();
    if(!minPos3)
      moveToMin(servo3, minPos3);
  }

  else if (val == "moveToMax4")
  {
    up_speed = MovingSpeed.toFloat();
    //Serial.print(minPos2);
    if(minPos4)
      moveToMax(servo4, minPos4);
    //Serial.print(minPos2);
  }
  else if (val == "moveToMin4")
  {
    down_speed = MovingSpeed.toFloat();
    if(!minPos4)
      moveToMin(servo4, minPos4);
  }
  
  else if (val == "moveToMax5")
  {
    up_speed = MovingSpeed.toFloat();
    //Serial.print(minPos2);
    if(minPos5)
      moveToMax(servo5, minPos5);
    //Serial.print(minPos2);
  }
  else if (val == "moveToMin5")
  {
    down_speed = MovingSpeed.toFloat();
    if(!minPos5)
      moveToMin(servo5, minPos5);
  }

    else if (val == "moveToMax6")
  {
    up_speed = MovingSpeed.toFloat();
    //Serial.print(minPos2);
    if(minPos6)
      moveToMax(servo6, minPos6);
    //Serial.print(minPos2);
  }
  else if (val == "moveToMin6")
  {
    down_speed = MovingSpeed.toFloat();
    if(!minPos6)
      moveToMin(servo6, minPos6);
  }
  //delay(10);

}

void moveToMin(Servo servo, bool& minPos)
{
    if (down_speed == 10)
    {
      for (int i = 0; i< 5; i++)
      {
      servo.write(max_pos);
      }
    }
      else
      {
  for (pos1 = min_pos; pos1 <= max_pos; pos1 += 1) { // goes from 0 degrees to 180 degrees
    // in steps of 1 degree
    servo.write(pos1);              // tell servo to go to position in variable 'pos'
    delay(10 - down_speed + 1); 
    //delay();// waits 15ms for the servo to reach the position
    }
      }

   minPos = true;
   //Serial.print("0");
}


void moveToMax(Servo servo, bool& minPos)
{
  if (up_speed == 10)
  {
      for (int i = 0; i < 5; i++)
      {
      servo.write(min_pos);
      }
  }
      else
      {
  for (pos1 = max_pos; pos1 >= min_pos; pos1 -= 1) { // goes from 180 degrees to 0 degrees
     servo.write(pos1);              // tell servo to go to position in variable 'pos'
     delay(10 - up_speed + 1);
     //delay(0.95);// waits 15ms for the servo to reach the position
    }
      }

   minPos = false;
}


