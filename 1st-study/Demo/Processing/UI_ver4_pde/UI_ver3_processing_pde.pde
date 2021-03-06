import processing.serial.*;
import controlP5.*;
import themidibus.*; //Import the library
import java.io.FilenameFilter;
import java.io.File;

ControlP5 cp5;

Button b1, b2, b3, b4, b5, b6, playButton, all_button, right_hand, stop;
DropdownList songList;
Song ToBePlayed;

Serial myPort;
String val;

boolean atDown1 = false, atDown2 = false, atDown3 = false, atDown4 = false, 
        atDown5 = false, atDown6 = false, all_up = true, right_up = true;

boolean stopFlag;

float up_speed;
float down_speed;

String inString;

boolean port_ready = false;

String[] scaling = {"6", "5", "4", "3", "2", "123", "654"};
Song scale = new Song(scaling, new float[] {1, 2, 3, 4, 5, 6, 7}, new String[] {"1", "2"});

//String[] song1Actions = {"1", "2", "3", "4", "5", "6"};
Song sallyGarden;
Song alignedBoy;
//Song oldAlignedBoy;
Song Exp1;
Song temp;

int SongNumber = 0;

boolean PlayPressed = false;
int start_time = 0;
int last_action_ix = -1;
//int count = 1;

String fileName;

float song_speed;
float[] scaled_times;

MidiBus myBus; // The MidiBus

void drawbackground()
{
  background(230);
  
  fill(color(170, 74, 48));
  noStroke();
  rect(80, 0, 70, 500);
  
  fill(color(0));
  noStroke();
  rect(200, 400, 30, 30);
  
  
  fill(color(255));
  noStroke();
  rect(200, 450, 30, 30);
  
  fill(125);
  textSize(10);
  text("down state", 250, 420);
  text("up state", 250, 470);
  
  //fill(color(125));
  textSize(24);
  text("Control Panel", 200, 80);
  
  //fill(color(0));
  //noStroke();
  //rect(410, 280, 30, 30);
  //text("all down", 450, 270);
  
  //fill(color(255));
  //noStroke();
  //rect(350, 280, 30, 30);
  //text("all up", 380, 270);
}

void setup()
{
  size(500, 500);
  drawbackground();
  frameRate(30);
  
  cp5 = new ControlP5(this);
  
  myBus = new MidiBus(this, -1, "SimpleSynth virtual input"); 
  
  b1 = cp5.addButton("First")
     //.setValue(0)
     .setPosition(100,100);
  KeyCustomize(b1);
  
  b2 = cp5.addButton("Second")
     //.setValue(0)
     .setPosition(100,150)
     ;
  KeyCustomize(b2);
     
  b3 = cp5.addButton("Third")
     //.setValue(0)
     .setPosition(100,200);
  KeyCustomize(b3);
  
  b4 = cp5.addButton("Fourth")
     //.setValue(0)
     .setPosition(100,300)
     ;
  KeyCustomize(b4);
  
  b5 = cp5.addButton("Fifth")
     //.setValue(0)
     .setPosition(100,350)
     ;
  KeyCustomize(b5);
  
  b6 = cp5.addButton("Sixth")
     .setPosition(100,400)
     ;
  KeyCustomize(b6);
     
  Slider slider_up = cp5.addSlider("key_up_speed")
     .setPosition(200,100)
     .setSize(200,20)
     .setRange(0,10)
     .setValue(10)
     .setColorLabel(color(128))
     ;
     
  Slider slider_down = cp5.addSlider("key_down_speed")
     .setPosition(200,130)
     .setSize(200,20)
     .setRange(0,10)
     .setValue(10)
     .setColorLabel(color(128))
     ;
     
  Slider song_speed_slider = cp5.addSlider("song_speed")
     .setPosition(200,200)
     .setSize(200,20)
     .setRange(0,10)
     .setValue(5)
     .setColorLabel(color(128))
     ;
     
  all_button = cp5.addButton("All")
     //.setValue(0)
     .setPosition(200,300)
     .setSize(130,30)
     //.activateBy(ControlP5.PRESSED)
     .setColorBackground(color(255))
     .setColorLabel(color(128))
     .setCaptionLabel("Moving All Buttons")
     //.setView(new CircularButton());
     ;
     
  right_hand = cp5.addButton("Right")
     //.setValue(0)
     .setPosition(350,300)
     .setSize(130,30)
     //.activateBy(ControlP5.PRESSED)
     .setColorBackground(color(255))
     .setColorLabel(color(128))
     .setCaptionLabel("Right Hand Keys")
     //.setView(new CircularButton());
     ;
     
     
  playButton = cp5.addButton("Play")
     //.setValue(0)
     .setPosition(200,230)
     .setSize(130,30)
     //.activateBy(ControlP5.PRESSED)
     .setColorBackground(color(255))
     .setColorLabel(color(128))
     //.setView(new CircularButton());
     ;
     
  stop = cp5.addButton("Stop")
   //.setValue(0)
     .setPosition(200,265)
     .setSize(130,30)
     //.activateBy(ControlP5.PRESSED)
     .setColorBackground(color(255))
     .setColorLabel(color(128))
     //.setView(new CircularButton());
     ;
     
  songList = cp5.addDropdownList("SongList");
  DropdownCustomize(songList);
  
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 115200); 
  //myPort.bufferUntil('\n');
  //println(portName);
  
  
  //key initializing
  //initialization();
  
  sallyGarden = loadFile("sallygarden.txt");
  alignedBoy = loadFile("aligned-boy.txt");
  //oldAlignedBoy = loadFile("oldAligned-boy.txt");
  temp = loadFile("sallygarden-first15.txt");
  Exp1 = loadFile("Exp-01-short.txt");
  //println(temp);
  
  //println(temp.actions);
  
}

class Song 
{
  String[] actions;
  float[] times;
  String[] keysPositions;
  public Song(String[] a, float[] t, String[] k)
  {
    actions = a;
    times = t;
    keysPositions = k;
  }
  
  public int play_scale(int last_action_ix, float start_time){
   //println("playscale called\n");
   if (last_action_ix + 1 == actions.length){
     PlayPressed = false;
     return last_action_ix +1;
   }
   float now = millis();
   float offset = (now - start_time)/1000;
   
   if (offset >= scaled_times[last_action_ix+1]){
     //println(now);
     //println(offset);
     String button_ixs = actions[last_action_ix+1]; //position info
     trigger_buttons(button_ixs);
     playMIDI(keysPositions[last_action_ix+1]);
     return last_action_ix + 1;
   }
   else{
     return last_action_ix;
   }
   
}

public void trigger_buttons(String ixs)
{
  for (int j=0; j<ixs.length(); j++) {
    char button_ix = ixs.charAt(j);
    if (button_ix == '1') {
        First();
        //println("first");
    } else if (button_ix == '2') {
        Second();
        //println("Second");
    } else if (button_ix == '3') {
        Third();
        //println("Third");
    } else if (button_ix == '4') {
        Fourth();
        //println("Fourth");
    } else if (button_ix == '5') {
        Fifth();
        //println("Fifth");
    } else if (button_ix == '6'){
        Sixth();
        //println("Sixth");
    }

  }
}
}

void DropdownCustomize(DropdownList ddl)
{
  
  File folder = new File("/Users/vanchan/Documents/Processing/UI_ver1_processing/UI_ver3_processing_pde");
  
  File [] fileArray = folder.listFiles(new FilenameFilter() { 
                 public boolean accept(File folder, String filename)
                      { return filename.endsWith(".txt"); }
        });
  ArrayList<String> fileStrings = new ArrayList<String>();
  
  if(fileArray!=null)
  {
    for (File temp: fileArray)
    {
       fileStrings.add(temp.getName() );
    }
  }
  
  ddl.setPosition(350,230)
     .setSize(130, 130)
     .close()
     .setBarHeight(30)
     .setItemHeight(30)
     .setItems(fileStrings)
     //.addItem("Scale", 0)
     //.addItem("Sallygarden", 1)
     //.addItem("Aligned-boy", 2)
     //.addItem("SallyGarden_fitst15", 3)
     //.addItem("Experiment-01", 4)
     .setCaptionLabel("Choose your song")
     .setColorBackground(color(0))
     .setColorLabel(color(128))
     ;   
}

void KeyCustomize(Button b)
{
  b.setSize(30,30)
   .setColorBackground(color(255))
   .setColorLabel(color(128))
   .setColorForeground(color(255))
   ;
}

boolean moveKey(Button b, String keyLabel, boolean Pressed)
{
  if(!Pressed)
  {
    //println(" button pressed");
    down_speed = cp5.getController("key_down_speed").getValue();
    //println("down");
    
    String passingString = "moveToMin" + keyLabel + "_" + str(down_speed) + "\n";
    //println(passingString);
    
    //myPort.write("moveToMax1\n");
    myPort.write(passingString);
    Pressed = true;
    b.setColorBackground(color(0));
    b.setColorForeground(color(0));
    return Pressed;
  }
  else
  {
    up_speed = cp5.getController("key_up_speed").getValue();
    //println("up");
    
    String passingString = "moveToMax" + keyLabel + "_" + str(up_speed) + "\n";
    //println(passingString);
    
    //myPort.write("moveToMax1\n");
    myPort.write(passingString);
    //myPort.write("moveToMin1\n");
    Pressed = false;
    b.setColorBackground(color(255));
    b.setColorForeground(color(255));
    return Pressed;
  }
}

void First()
{
  atDown1 = moveKey(b1, new String("1"), atDown1);
  //println(Pressed1);
}

public void Second()
{ 
  atDown2 = moveKey(b2, new String("2"), atDown2);
  //println(Pressed1);
}

public void Third()
{ 
  atDown3 = moveKey(b3, new String("3"), atDown3);
  //println(Pressed1);
}

public void Fourth()
{ 
  atDown4 = moveKey(b4, new String("4"), atDown4);
}

public void Fifth()
{ 
  atDown5 = moveKey(b5, new String("5"), atDown5);
}


public void Sixth()
{
  atDown6 = moveKey(b6, new String("6"), atDown6);
}


public void All()
{ 
  if(all_up)
  {
    if(!atDown1)
    {
      First();
    }
    if(!atDown2)
    {
      Second();
    }
    if(!atDown3)
    {
      Third();
    }
    if(!atDown4)
    {
      Fourth();
    }
    if(!atDown5)
    {
      Fifth();
    }
    if(!atDown6)
    {
      Sixth();
    }
    all_up = false;
    all_button.setColorBackground(color(0));
    all_button.setColorForeground(color(0));
  }
  
  else
  {
    if(atDown1)
    {
      First();
    }
    if(atDown2)
    {
      Second();
    }
    if(atDown3)
    {
      Third();
    }
    if(atDown4)
    {
      Fourth();
    }
    if(atDown5)
    {
      Fifth();
    }
    if(atDown6)
    {
      Sixth();
    }
    all_up = true;
    all_button.setColorBackground(color(255));
    all_button.setColorForeground(color(255));
  }
}

public void Right()
{
  if(right_up)
  {
    if(!atDown4)
    {
      Fourth();
    }
    if(!atDown5)
    {
      Fifth();
    }
    if(!atDown6)
    {
      Sixth();
    }
    right_up = false;
    right_hand.setColorBackground(color(0));
    right_hand.setColorForeground(color(0));
  }
  
  else
  {
    if(atDown4)
    {
      Fourth();
    }
    if(atDown5)
    {
      Fifth();
    }
    if(atDown6)
    {
      Sixth();
    }
    right_up = true;
    right_hand.setColorBackground(color(255));
    right_hand.setColorForeground(color(255));
  }
}

public void SongList()
{
  //println(songList.getValue());
  SongNumber = int(songList.getValue());
}

void draw() 
{  
  drawbackground();
  
  if(myPort.available() > 0 && !port_ready)
  {
    val = myPort.readStringUntil('\n');
    port_ready = true;
  }
  
  if(PlayPressed == true)
  { 
    //if(SongNumber == 0)
    //  last_action_ix = scale.play_scale(last_action_ix, start_time); 
    //else if(SongNumber == 1) {
    //  last_action_ix = sallyGarden.play_scale(last_action_ix, start_time); 
    //  //fileName = "sallygarden.txt";
    //  //loadFile(fileName);
    //}
    //else if(SongNumber == 2)
    //  last_action_ix = alignedBoy.play_scale(last_action_ix, start_time); 
    //else if(SongNumber == 3) {
    //  last_action_ix = temp.play_scale(last_action_ix, start_time); 
      
    //}
    //else if(SongNumber == 4)
    //  last_action_ix = Exp1.play_scale(last_action_ix, start_time);
    
    last_action_ix = ToBePlayed.play_scale(last_action_ix, start_time);
  }
}

float[] changeSongSpeed(float[] time)
{
  //println(time);
  song_speed = cp5.getController("song_speed").getValue();
  float gap = (10 - song_speed) / 10;
  float c = 0;
  float[] new_time = new float[time.length];
  arrayCopy(time, new_time);
  //println(time[5]);
  //new_time[5] = new_time[5] + 1;
  //println(time[5]);
  //println(new_time[5]);
  //println(gap);
  for (int i = 0; i < time.length; i++)
  {
      new_time[i] = time[i] + c;
      c = c + gap;
      //println(time[i]);
      //println(new_time[i]);
  }
  println(new_time);
  return new_time;
}

void serialEvent(Serial p) {
  inString = p.readString();
  //if(inString != null)
      //print(inString);
}

public void Stop()
{
  
  PlayPressed =false;
  if(stopFlag==false)
  {
    All();
    stopFlag=true;
  }
  
  ToBePlayed = null;  
  last_action_ix = -1;
  
}

public void Play()
{
   PlayPressed = true;
   
   File folder = new File("/Users/vanchan/Documents/Processing/UI_ver1_processing/UI_ver3_processing_pde");
   stopFlag=false;
   File [] fileArray = folder.listFiles(new FilenameFilter() { 
                 public boolean accept(File folder, String filename)
                      { return filename.endsWith(".txt"); }
        });
   ArrayList<String> fileStrings = new ArrayList<String>();
  
  
   for (File temp: fileArray)
   {
      fileStrings.add(temp.getName() );
   }
  
   ToBePlayed = loadFile(fileStrings.get(SongNumber));
   scaled_times = changeSongSpeed(ToBePlayed.times);
   
   //println(temp.times);
   
   //scaled_times = changeSongSpeed(temp.times);
   //println(temp.times);
   
   //if(SongNumber == 0)
   //   scaled_times = changeSongSpeed(scale.times); 
   // else if(SongNumber == 1) {
   //   scaled_times = changeSongSpeed(sallyGarden.times); 
   //   //fileName = "sallygarden.txt";
   //   //loadFile(fileName);
   // }
   // else if(SongNumber == 2)
   //   scaled_times = changeSongSpeed(alignedBoy.times);
   // else if(SongNumber == 3) {
   //   scaled_times = changeSongSpeed(temp.times); 
   // }
   // else if(SongNumber == 4)
   //   scaled_times = changeSongSpeed(Exp1.times); 
      
      
   start_time = millis();
   last_action_ix = -1;
}


Song loadFile(String fName)
{
  String lines[] = loadStrings(fName);
  //println(lines.length);
  float pitches[] = new float[lines.length];
  float times[] = new float[lines.length];
  String keysPos[] = new String[lines.length];
  String keyActions[] = new String[lines.length];
  
  //println(lines.length);
  for (int i = 0 ; i < lines.length; i++) {
  //println(lines[i]);
    String[] items = lines[i].split("\t");
    pitches[i] = float(items[0]);
    times[i] = float(items[2]);
    
    keysPos[i] = pitch2keys(pitches[i]);
    
    if (i >= 1)
    {
      keyActions[i] = Pos2Actions(keysPos[i - 1], keysPos[i]);
    }
  }
  
  keyActions[0] = "";
  for (int i = 0; i < keysPos[0].length(); i ++){
    if (keysPos[0].charAt(i) != '0')
    {
      keyActions[0] = keyActions[0] + str(i+1);
    } 
  }
  
  //println(times);
  //println(times);
  Song newSong = new Song(keyActions, times, keysPos);
  return newSong;
}

String pitch2keys(float pitch)
{
  int tempPitch = int(pitch) % 12;
  if(tempPitch == 0)
    return "123000";
  else if(tempPitch == 2)
    return "120000";
  else if(tempPitch == 4)
    return "100000";
  else if(tempPitch == 5)
    return "023000";
  else if(tempPitch == 7)
    return "123456";
  else if(tempPitch == 9)
    return "123450";
  else if(tempPitch == 11)
    return "123400";
  else 
  {
    println("pitch should not contain any half notes\n");
    return "0";
  }    
}

String Pos2Actions(String prePos, String proPos)
{
  String actions = "";
  for (int i = 0; i < prePos.length(); i ++){
    if (prePos.charAt(i) != proPos.charAt(i))
    {
      actions = actions + str(i+1);
    } 
  }  
  
  return actions;
}

int getPitch(String pos)
{
  //println(pos);
  int pitch;
  if(pos.equals("123000") || pos.equals("123006"))
    pitch = 60;
  //else if(pos.equals("110000"))
  else if(pos.substring(0, 4).equals("1200"))
    pitch = 62;
  //else if(pos.equals("100000"))
  else if(pos.substring(0, 3).equals("100"))
    pitch = 64;
  else if(pos.equals("023000"))
    pitch = 65;
  else if(pos.equals("123456") || pos.equals("023456"))
    pitch = 55;
  else if(pos.equals("123450"))
    pitch = 57;
  else if(pos.equals("123400"))
    pitch = 59;
  else if(pos.charAt(0) == '0' && pos.charAt(1) == '2' && pos.charAt(2) == '3')
  {
    pitch = 66;
    //println("011xxx");
  }
  else if(pos.charAt(0) == '0' && pos.charAt(1) == '2' )
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

void playMIDI(String pos)
{
  println(pos);
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