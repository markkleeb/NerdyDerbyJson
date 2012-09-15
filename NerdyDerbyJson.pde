import processing.serial.*; 
import org.json.*;
import httprocessing.*;

PFont font; 
String postsite = "http://nerdyderby.herokuapp.com/races/new";

Serial myPort;    // The serial port: 
int startTime = 0;
int track1FinishTime = 0;
int track2FinishTime = 0;
int track3FinishTime = 0;
int firstPlace = 0;
int secondPlace = 0;
int thirdPlace = 0;

boolean allcars= false;

int carIndex = 0;

String[] carlist = new String[3];




boolean racing = false;
boolean reset = true;

void setup() { 
  size(1050, 800); 
  
  for(int i = 0; i < 3; i++){
   carlist[i] = ""; 
  }
  // myPort = new Serial(this, Serial.list()[0], 115200); //Arduino transmitting at 115200
  // myPort.buffer(0);
  font = loadFont("SynchroLET-60.vlw");
  textFont(font, 60);

  //variables for RFID tags until reader works


}

void draw() {
  background(0);
  

 

  if (racing == true) {
    fill(255);
    textAlign(LEFT, CENTER);
    text("TRACK 1", 50, 150);
    text("TRACK 2", 383, 150);
    text("TRACK 3", 716, 150);
    if (track1FinishTime != 9999999) {
      text(timestamp(track1FinishTime), 50, 200);
      if ( (track1FinishTime < track2FinishTime) && (track1FinishTime < track3FinishTime))
      {
        text("FIRST!", 50, 300);
      }
      else if ((track1FinishTime <= track2FinishTime) || (track1FinishTime <= track3FinishTime) )
      {
        text("SECOND!", 50, 300);
      }
      else
      {
        text("THIRD!", 50, 300);
      }
    }
    else {
      text(timestamp(millis() - startTime), 50, 200);
    }
    if (track2FinishTime != 9999999) {
      text(timestamp(track2FinishTime), 383, 200);
      if ( (track2FinishTime < track1FinishTime) && (track2FinishTime < track3FinishTime))
      {
        text("FIRST!", 383, 300);
      }
      else if ((track2FinishTime <= track1FinishTime) || (track2FinishTime <= track3FinishTime) )
      {
        text("SECOND!", 383, 300);
      }
      else
      {
        text("THIRD!", 383, 300);
      }
    }  
    else {
      text(timestamp(millis() - startTime), 383, 200);
    }
    if (track3FinishTime != 9999999) {
      text(timestamp(track3FinishTime), 716, 200);
      if ( (track3FinishTime < track1FinishTime) && (track3FinishTime < track2FinishTime))
      {
        text("FIRST!", 716, 300);
      }
      else if ((track3FinishTime <= track1FinishTime) || (track3FinishTime <= track2FinishTime) )
      {
        text("SECOND!", 716, 300);
      }
      else
      {
        text("THIRD!", 716, 300);
      }
    }
    else {
      text(timestamp(millis() - startTime), 716, 200);
    }
  }
  else { // After "RESET" signal sent:


    background(0);
    textAlign(CENTER, CENTER);

    if (allcars) {
      text("READY TO RACE!", width/2, height/2);
    }
    else {
      text("Waiting for Car " + (carIndex+1), width/2, height/2);
    }
  }
}

void keyPressed() {
  rfid();
}

void rfid() {

  boolean waiting = true;
  if (carIndex < 3) {
    if (key != '\n' && waiting == true) {
      carlist[carIndex] += key;
    }
    else {
      waiting = false;
      carIndex++;
      println(carlist[0] + " " + carlist[1] + " " + carlist[2]);
    }
  }

  if (carIndex == 3) {
    allcars = true;
  }
}


void serialEvent (Serial myPort) {
  char c = char(myPort.read());
  switch (c) {
  case 'R':
    postData();
    racing = false;
    track1FinishTime = 0;
    track2FinishTime = 0;
    track3FinishTime = 0;
    break;
  case '0': 
    println("RACE STARTED!");
    racing = true;
    startTime = millis();
    track1FinishTime = 9999999;
    track2FinishTime = 9999999;
    track3FinishTime = 9999999;
    break;
  case '1':
    track1FinishTime = millis() - startTime;
    println("1: " + track1FinishTime);
    break;
  case '2':
    track2FinishTime = millis() - startTime;
    println("2: " + track2FinishTime);
    break;
  case '3':
    track3FinishTime = millis() - startTime;
    println("3: " + track3FinishTime);
    break;
  case 'E':
    println("TRACK ERROR!");
  case 'A':
    println("TRACK 1 ERROR!");
  case 'B':
    println("TRACK 2 ERROR!");
  case 'C':
    println("TRACK 3 ERROR!");
  }
}

void postData() {

  // 1. Initialize the Array
  JSONArray race = new JSONArray();


  // 2. Create the first object & add to array
  JSONObject firstTrack = new JSONObject();
  firstTrack.put( "rfid", carlist[0] );
  firstTrack.put( "duration", track1FinishTime );
  race.put( firstTrack );

  // 3. Create the second object
  JSONObject secondTrack= new JSONObject();
  secondTrack.put( "rfid", carlist[1] );
  secondTrack.put( "duration", track2FinishTime );
  race.put( secondTrack );


  JSONObject thirdTrack = new JSONObject();
  thirdTrack.put( "rfid", carlist[2] );
  thirdTrack.put( "duration", track3FinishTime );
  race.put( thirdTrack );


  PostRequest post = new PostRequest(postsite);
  post.addData("cars", race.toString());


  post.send();

  //check to make sure post is sent
  println("Reponse Content: " + post.getContent());
  println("Reponse Content-Length Header: " + post.getHeader("Content-Length"));
}

String timestamp(int elapse) {
  //convert to MM:SS:HH

  int minutes = elapse / (1000*60) % 60;
  int seconds = elapse / (1000) % 60;
  int hundredsec = elapse / 10;

  return (nf(minutes, 2) + ":" + nf(seconds, 2) + "." + nf(hundredsec, 1));
}

