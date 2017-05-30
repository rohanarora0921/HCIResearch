import processing.serial.*;
import themidibus.*; //Import the library
import controlP5.*;

ControlP5 cp5;
Button evaluation, retry, exit;

Serial myPort;

String inString;

int[] keys = new int[6];
int[] preKeys = new int[6];

String[] notes = new String[1];
float[] timing = new float[1];

int [] pitches = new int[1];
int [] des_pitches = new int[1];
float[] des_timing = new float[1];

float startTime;

MidiBus myBus; // The MidiBus

String[] desNotes = new String[1];

Table table;
int tableRowCount = 0;
int trialCount = 0;
String currentTrialName;
String currentTiming;
    
void setup()
{
  size(100, 200);
  cp5 = new ControlP5(this);
  
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600); 
  
  for (int i = 0; i < 6; i++)
  {  
    keys[i] = 0;
    preKeys[i] = 0;
  }
  
  notes[0] = "000000";
  timing[0] = 0.00;
  desNotes[0] = "000000";
  pitches [0] = 0;
  des_pitches[0] = 0;
 
  startTime = millis();
  
  frameRate(100);
  //delay(10);
  
  myBus = new MidiBus(this, -1, "SimpleSynth virtual input"); 
  
  table = new Table();
  
  table.addColumn("index");
  table.addColumn("destination");
  table.addColumn("des_timing");
  
  TableRow newRow = table.addRow();
    
  newRow.setInt("index", tableRowCount);
  newRow.setInt("destination", 0);
  newRow.setFloat("des_timing", 0);
  tableRowCount = tableRowCount + 1;
    
  readDesNotes("Exp-01-short.txt");
  
  evaluation = cp5.addButton("Evaluate")
            .setSize(50, 30)
            .setPosition(10, 10);
            
  retry = cp5.addButton("Start")
          .setSize(50, 30)
          .setPosition(10, 50);
  exit = cp5.addButton("Exit")
          .setSize(50, 30)
          .setPosition(10, 100);
  
  
}

void draw()
{
  if(myPort.available() > 0)
  {
    inString = myPort.readStringUntil('\n');
    //println(inString);
    coveredKeys();
    compareNotes(preKeys, keys);
    
  }
}


void compareNotes(int[] pre, int[] now)
{
  //println("pre:" + str(pre));
  String pk = str(pre[0]) + str(pre[1]) + str(pre[2]) 
      + str(pre[3]) + str(pre[4]) + str(pre[5]);
  String k = str(now[0]) + str(now[1]) + str(now[2]) 
      + str(now[3]) + str(now[4]) + str(now[5]);  
  //println("pre:" + pk);
  //println("now:" + k);
  //println(pk.equals(k));
  if(!pk.equals(k))
  {
    //String temp = str(now[0]) + str(now[1]) + str(now[2]) 
     // + str(now[3]) + str(now[4]) + str(now[5]);    
    playMIDI(k);
    
    float currentTime = (millis() - startTime) / 1000.000;
    
    if(currentTime - timing[timing.length - 1] <= 0.1)
    {
      notes[notes.length - 1] = k;
      timing[timing.length - 1] = currentTime;
      pitches[pitches.length - 1] = getPitch(k);
      //println(notes[notes.length - 1]);
    }
    
    else
    {
      notes = append(notes, k);
      timing = append(timing, currentTime);
      pitches = append(pitches, getPitch(k));
      //println(k + "   " + currentTime);
      //println(notes[notes.length - 1]);
    }
    //println(notes);
    //println("pre != now");
  
    //println(currentTime);
    //println(notes[notes.length - 1]);
    arrayCopy(now, preKeys); 
  }
}

void playMIDI(String pos)
{
  //println(pos);
  int channel = 0;
  int pitch;
  int velocity = 127;
  
  pitch = getPitch(pos);
  if(pitch == 0)
  {
    velocity = 0;
  }
    
  myBus.sendNoteOn(channel, pitch, 0); 
  myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
  
  int number = 0;
  int value = 90;

  myBus.sendControllerChange(channel, number, value);
  
  //pitches = append(des_pitches, pitch);
}


int getPitch(String pos)
{
  int pitch;
  if(pos.equals("111000") || pos.equals("111001"))
    pitch = 60;
  //else if(pos.equals("110000"))
  else if(pos.substring(0, 4).equals("1100"))
    pitch = 62;
  //else if(pos.equals("100000"))
  else if(pos.substring(0, 3).equals("100"))
    pitch = 64;
  else if(pos.equals("011000"))
    pitch = 65;
  else if(pos.equals("111111") || pos.equals("011111"))
    pitch = 55;
  else if(pos.equals("111110"))
    pitch = 57;
  else if(pos.equals("111100"))
    pitch = 59;
  else if(pos.charAt(0) == '0' && pos.charAt(1) == '1' && pos.charAt(2) == '1')
  {
    pitch = 66;
    //println("011xxx");
  }
  else if(pos.charAt(0) == '0' && pos.charAt(1) == '1' )
  {
    pitch = 65;
    //println("01xxxx");
  }
  else
  {
    pitch = 0;
    //println("else");
    //velocity = 0;
  }
  return pitch;
}

void coveredKeys()
{
  //inString = myPort.readStringUntil('\n');
  //println(inString + "length=" + inString.length());
  if (inString != null && inString.length() >= 13 && inString.length() <= 19)
  //println(inString);
  //if (inString != null)
  {
    //println(inString + "length=" + inString.length());
    //println(inString);
    String[] values = inString.split(",");
    
    if(values.length == 6)
    {
      values[5] = trim(values[5]);
      //println("================" + values.length);
      //int l = values.length;
      for (int i = 0; i < values.length; i++)
      {
        //println("================" + values.length);
        //println(values);
        if(int(values[i]) >= 15)
          keys[i] = 1;
        else
          keys[i] = 0;
      }
    //println(int(values[5]));
      inString = null;
    }
  }
  
  //return keys;
}

void readDesNotes(String filename)
{
  String lines[] = loadStrings(filename);
  float p[] = new float[lines.length];
  float t[] = new float[lines.length];
  
  for(int i = 0; i < lines.length; i++)
  {
    String[] items = lines[i].split("\t");
    p[i] = float(items[0]);
    t[i] = float(items[2]);
    
    desNotes = append(desNotes, pitch2keys(p[i]));
    des_pitches = append(des_pitches, int(p[i]));
    //des_timing = append(des_timing, t[i]);
    
    TableRow newRow = table.addRow();
    
    newRow.setInt("index", tableRowCount);
    newRow.setInt("destination", int(p[i]));
    newRow.setFloat("des_timing", t[i]);
    
    tableRowCount = tableRowCount + 1;
  }
  
  //println(pitches);
  desNotes = append(desNotes, "000000");
  des_pitches = append(des_pitches, 0);
  
  TableRow newRow = table.addRow();
    
  newRow.setInt("index", tableRowCount);
  newRow.setInt("destination", 0);
    
  //tableRowCount = 0;
  
  println(desNotes);
  //println(des_pitches.length);
  
  //saveTable(table, "table.csv");
}

String pitch2keys(float pitch)
{
  int tempPitch = int(pitch) % 12;
  if(tempPitch == 0)
    return "111000";
  else if(tempPitch == 2)
    return "110000";
  else if(tempPitch == 4)
    return "100000";
  else if(tempPitch == 5)
    return "011000";
  else if(tempPitch == 7)
    return "111111";
  else if(tempPitch == 9)
    return "111110";
  else if(tempPitch == 11)
    return "111100";
  else 
  {
    println("pitch should not contain any half notes\n");
    return "0";
  }    
}

void Exit()
{
  println("==================Exit===================");
  println(notes);
  
  exit();
}

void Start()
{
  notes = new String[1];
  notes[0] = "000000";
  timing = new float[1];
  timing[0] = 0.00;
  pitches = new int[1];
  pitches[0] = 0;
  
  currentTrialName = "Trail" + str(trialCount);
  currentTiming = "Timing" + str(trialCount);
  
  table.addColumn(currentTrialName);
  table.addColumn(currentTiming);
  
  //TableRow newRow = table.addRow();    
  tableRowCount = 0;
  table.setInt(tableRowCount, currentTrialName, 0);
  
  //tableRowCount = 1;
  
  println("=====Retry=====");
  
  startTime = millis();
  table.setInt(tableRowCount, currentTiming, 0);
}

void Evaluate ()
{
  for(int i = 0; i < pitches.length; i++)
  {
    //TableRow newRow = table.addRow();    
    table.setInt(tableRowCount, currentTrialName, pitches[i]);
    table.setFloat(tableRowCount, currentTiming, timing[i]);
    tableRowCount = tableRowCount + 1;
  }
  
  trialCount = trialCount + 1;
  //tableRowCount = 1;
  
  if(evaluation(pitches, des_pitches))
  {
    println("CORRECT");
    table.setString(tableRowCount + 1 , currentTrialName, "CORRECT");
  }
  else
  {
    //println(pitches);
    {
    println("WRONG");
    table.setString(tableRowCount + 1 , currentTrialName, "WRONG");
    }
  }
  
  table.addColumn("Ratio");
  saveTable(table, "table.csv");
}


boolean evaluation(int[] testing, int[] des)
{
  
  if(testing.length != des.length)
  {
    println("length incorrect");
    return false;
  }
    
  for(int i = 0; i < testing.length; i++)
  {
    if (testing[i] != (des[i]))
    {
      println("notes_" + str(i) + "_incorrect");
      println("notes: " + testing[i] + "     des:" + des[i]);
      return false;
    }
  }
  return true;
}