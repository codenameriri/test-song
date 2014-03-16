import themidibus.*;
import processing.serial.*;
import org.firmata.*;
import cc.arduino.*;

// Timekeeping
int BPM = 80;
int last = 0;
int last2 = 0;

// Key press
boolean keyDown = false;
char lastKey = '1';
boolean playing = false;

// Arduino
Arduino arduino;
String ARDUINO_PORT = "COM3";
//String ARDUINO_PORT = "/dev/tty.usbmodem411";
int potPin = 2;
float potVal = 0;

// MidiBus
MidiBus mb;
String MIDI_PORT_OUT = "Virtual MIDI Bus";
int channel1 = 0;
int channel2 = 1;
int channel3 = 2;
int channel4 = 3;

// Riri Stuff
//RiriNote beat = new RiriNote();
RiriSequence beat = new RiriSequence();
//RiriLoop beat = new RiriLoop();
RiriSequence[] tracks = new RiriSequence[3];

// Other stuff
int[] pitchesInC = {60, 62, 64, 67, 69, 72};
int[] pitchesInF = {65, 67, 69, 72, 74, 77};
float[] intervals = {2, 1, .5, .25};
float interval = 0;
float interval2 = 0;
int pitch = 0;
int pitch2 = 0;

int beatsToMils(float beats){
  // (one second split into single beats) * # needed
  float convertedNumber = (60000 / BPM) * beats;
  return (int) convertedNumber;
}

void setup() {
  size(400,400);
  background(0,0,0);
  // Setup Arduino
  //println(Arduino.list());
  //arduino = new Arduino(this, ARDUINO_PORT, 57600);
  // Setup MidiBus
  MidiBus.list();
  mb = new MidiBus(this, -1, MIDI_PORT_OUT);
  //mb.sendTimestamps();
}

void draw() {
  if (playing) {
    if (lastKey == '1') {
      playTestOne();
    }
    else if (lastKey == '2') {
      playTestTwo();
    }
    else if (lastKey == '3') {
      playTestThree();
    }
    else {
      playTestOne();
    }
  }
}

void play() {
  // Start tracks
  beat.start();
  for (int i = 0; i < tracks.length; i++) {
    if (tracks[i] != null) {
      tracks[i].start();
    }
  }
  // Set playing true
  playing = true;
  println("PLAYING");
}

void stop() {
  // Stop tracks
  beat.quit();
  for (int i = 0; i < tracks.length; i++) {
    if (tracks[i] != null) {
      tracks[i].quit();
      tracks[i] = null;
    }
  }
  // Set playing false
  playing = false;
  println("STOPPING");
}

void keyPressed() {
	if (!keyDown) {
		if (key == ' ') {
			if (playing) {
				stop();
			}
			else {
        if (lastKey == '1') {
          setupTestOne();
        }
        else if (lastKey == '2') {
          setupTestTwo();
        }
        else if (lastKey == '3') {
          setupTestThree();
        }
        else {
          setupTestOne();
        }
				play();
			}
		}
    else {
      lastKey = key;
      println("Last key is "+lastKey);
    }
	}
  keyDown = true;
}

void keyReleased() {
	keyDown = false;
}

/*
* Test One - 4/4 time, 80 BPM, C pentatonic scale
* 
* beat = a repeating 1 measure groove
* tracks[0] = a randomly generated melody, based on C pentatonic scale
* tracks[1] = a randomly assigned chord, component notes fit the C pentatonic scale
* tracks[2] = a bass track, uses the same roon note assigned to the tracks[1] chord
*/
void setupTestOne() {
  // Set the BPM
  BPM = 80;
  last = 0;
  last2 = 0;
  // Setup the beat
  beat = new RiriSequence();
  beat.addNote(channel1, 36, 120, beatsToMils(.5));
  beat.addNote(channel1, 36, 120, beatsToMils(1));
  beat.addNote(channel1, 36, 120, beatsToMils(1));
  beat.addNote(channel1, 36, 120, beatsToMils(.5));
  beat.addNote(channel1, 36, 120, beatsToMils(.25));
  beat.addNote(channel1, 36, 120, beatsToMils(.75));
  beat.infinite(true);
  // Setup the melody and harmony
  tracks[0] = new RiriSequence();
  tracks[0].addNote(channel2, 60, 100, beatsToMils(4));
  tracks[1] = new RiriSequence();
  tracks[1].addNote(channel3, 48, 100, beatsToMils(4));
  tracks[2] = new RiriSequence();
  tracks[2].addNote(channel4, 60 - 36, 100, beatsToMils(4));
}

void playTestOne() {
  // Add a new note to the melody
  if (millis() > last + 100) {
    last = millis();
    int p = pitchesInC[(int) random(0, pitchesInC.length)];
    tracks[0].addNote(channel2, p, 100, beatsToMils(.25));
  }
  // Prepare the next chord and bass note
  if (millis() > last2 + 1000) {
    last2 = millis();
    int r = (int) random(0, pitchesInC.length - 2);
    RiriChord chord = new RiriChord();
    chord.addNote(channel3, pitchesInC[r] - 12, 100, beatsToMils(2));
    chord.addNote(channel3, pitchesInC[r+2] - 12, 100, beatsToMils(2));
    tracks[1].addChord(chord);
    tracks[2].addNote(channel4, pitchesInC[r] - 36, 100, beatsToMils(1));
    tracks[2].addNote(channel4, pitchesInC[r] - 36, 100, beatsToMils(1));
  }
}

/*
* Test Two - 4/4 time, 120 BPM, F pentatonic scale
*
* beat = a repeating 2 measure groove
* tracks[0] = bass track, generative, slower moving than main melody
* tracks[1] = main melody, generative, faster than bass track
*/
void setupTestTwo() {
  // Set the BPM
  BPM = 120;
  last = 0;
  last2 = 0;
  // Setup the beat
  beat = new RiriSequence();
  beat.addNote(channel1, 36, 100, beatsToMils(1.5));
  beat.addNote(channel1, 36, 80, beatsToMils(.5));
  beat.addNote(channel1, 38, 100, beatsToMils(2));
  beat.addNote(channel1, 36, 100, beatsToMils(.67));
  beat.addNote(channel1, 36, 80, beatsToMils(.67));
  beat.addNote(channel1, 36, 80, beatsToMils(.67));
  beat.addNote(channel1, 38, 100, beatsToMils(2));
  beat.infinite(true);
  // Setup the bass and treble 
  pitch = 0;
  tracks[0] = new RiriSequence();
  tracks[0].addNote(channel4, pitchesInF[pitch] - 36, 100, beatsToMils(1));
  pitch2 = 0;
  tracks[1] = new RiriSequence();
  tracks[1].addNote(channel2, pitchesInF[pitch2], 100, beatsToMils(1));
}

void playTestTwo() {
  if (playing) {
    // Add the next bass note
    if (millis() > last + interval/2) {
      last = millis();
      interval = intervals[(int) random(0, 2)];
      pitch = pitch + (int) random(-2, 2);
      if (pitch >= pitchesInF.length || pitch < 0) {
        pitch = 0;
      }
      tracks[0].addNote(channel4, pitchesInF[pitch] - 36, 100, beatsToMils(interval));
    }
    // Add the next treble note
    if (millis() > last2 + interval2/2) {
      last2 = millis();
      interval2 = intervals[(int) random(1, 3)];
      pitch2 = (int) random(0, pitchesInF.length);
      tracks[1].addNote(channel2, pitchesInF[pitch2], 100, beatsToMils(interval2));
    }
  }
}

/*
* Test Three - Change the pitch of notes within a sequence
*
*
*/
void setupTestThree() {
  // Set the BPM
  BPM = 80;
  last = millis();
  last2 = 0;
  // Setup the beat
  beat = new RiriSequence();
  beat.addNote(channel4, pitchesInC[0] - 36, 100, beatsToMils(.125));
  beat.addRest(channel4, beatsToMils(.125));
  beat.infinite(true);
  // Setup the tracks
  tracks[0] = new RiriSequence();
  tracks[0].addNote(channel2, pitchesInC[0], 100, beatsToMils(4));
  tracks[1] = new RiriSequence();
  tracks[1].addNote(channel3, pitchesInC[0] - 12, 100, beatsToMils(4));
}

void playTestThree() {
  if (playing) {
    if (millis() > last + beatsToMils(2)) {
      last = millis();
      // Update the beat's pitch
      int p = pitchesInC[(int) random(0, pitchesInC.length)];
      RiriNote tmp = (RiriNote) beat.notes().get(0);
      tmp.pitch = p - 36;
      // Update the tracks to match
      tracks[0].addNote(channel2, p, 100, beatsToMils(.75));
      tracks[0].addNote(channel2, pitchesInC[2], 100, beatsToMils(.25));
      tracks[0].addNote(channel2, pitchesInC[1], 100, beatsToMils(.25));
      tracks[0].addNote(channel2, pitchesInC[0], 100, beatsToMils(.75));
      RiriChord c = new RiriChord();
      int p2 = p % pitchesInC.length;
      int p3 = (p2 + 2) % pitchesInC.length;
      c.addNote(channel3, pitchesInC[p2] - 12, 100, beatsToMils(2));
      c.addNote(channel3, pitchesInC[p3] - 12, 100, beatsToMils(2));
      tracks[1].addChord(c);
    }
  }
}