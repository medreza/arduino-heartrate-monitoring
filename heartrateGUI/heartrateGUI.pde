// Based on examples from Arduino's Graphing Tutorial and OscP5 documentation
    import processing.serial.*;
    Serial myPort; // The serial port
    int xPos = 1; // horizontal position of the graph
    float oldHeartrateHeight = 0; // for storing the previous reading
    int videoScale = 50;
    int cols, rows;
    int peak = 0;
    float heartanim;
   float heartsize;
    int BPM;
    int IBI;
    int currentHeartrate;
    boolean beat;
   PImage img;
   PImage imgbg;
    void setup () {
    // set the window size:
    img = loadImage("bg1.jpg");
    imgbg = loadImage("bg2.jpg");
    size(800, 400);
    frameRate(60);
    cols = 600/videoScale;
    rows = height/videoScale;
    int runonce = 0;
    // List available serial ports.
    println(Serial.list());

    // Setup which serial port to use.
    // This line might change for different computers.
    myPort = new Serial(this, "COM20", 115200);
textSize(20);
    // set inital background:
    background(255);
    
    
      for (int i = 0; i < cols; i++) {
    // Begin loop for rows
    for (int j = 0; j < rows; j++) {
      
      // Scaling up to draw a rectangle at (x,y)
      int x = i*videoScale;
      int y = j*videoScale;
      noFill();
      stroke(1);
      // For every column and row, a rectangle is drawn at an (x,y) location scaled and sized by videoScale.
      rect(x,y,videoScale,videoScale); 
      noStroke();
    }
  }
  
    }
    
    
    void grid(){
          for (int i = 0; i < cols; i++) {
    // Begin loop for rows
    for (int j = 0; j < rows; j++) {
      
      // Scaling up to draw a rectangle at (x,y)
      int x = i*videoScale;
      int y = j*videoScale;
      noFill();
      stroke(1);
      // For every column and row, a rectangle is drawn at an (x,y) location scaled and sized by videoScale.
      rect(x,y,videoScale,videoScale); 
      noStroke();
    }
  }
    }

    void draw () {
      noStroke();
      // Begin loop for columns
          fill(255,255,255);
    rect(602,0,198,400);
    noFill();
    
         fill(0,255,0);
    //rect(0,400,800,49);
    //rect(0,0,600,50);
   // image(imgbg, 0, 400);
    image(img, 0, 0);
    image(imgbg, 692, 212);
    noFill();
      // DRAW THE HEART AND MAYBE MAKE IT BEAT
  fill(250,0,0);
  stroke(250,0,0);
  // the 'heart' variable is set in serialEvent when arduino sees a beat happen
//float heartanim2 = map(heartanim, 0 ,height, 0, 20);
///heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
  //heart = max(heart,0);       // don't let the heart variable go into negative numbers
  //if (heart > 0){             // if a beat happened recently, 
    //strokeWeight(8);          // make the heart big
  //}
  
  heartsize = map(heartanim,0.0,height,150.0,255.0);
  //heartsize = max(0,20);
  //stroke(10);
  if (heartsize >=150 && heartsize <=255){
  //strokeWeight(heartsize); 
  fill(heartsize,0,0);
  } /*else {
    heartsize = 1.0;
   strokeWeight(heartsize);
  }*/
  beginShape();
  smooth();   // draw the heart with two bezier curves
  bezier(width-100,70, width-50,-10, width-20,120, width-100,130);
  bezier(width-100,70, width-160,-10, width-180,120, width-100,130);
 strokeWeight(1);          // reset the strokeWeight for next time
 endShape();
 noStroke();
//  text("Heartstroke: " + heartanim2,300,420);
 //  fill(0,255,0);
   // rect(0,400,800,49);
    //rect(0,0,600,50);
    fill(0,0,0);
    //text("Heart Beat Monitoring - ELINSUGM ",200,20);
    //text("heartsize :" + heartsize,250,440);
    //text("Instrumentasi Elektronik 2014 ",220,40);
        text("ADC Peak: " + peak,610,190);
        text("ADC: " + currentHeartrate,610,170);
        if (beat == true) {
            text("BPM: " + BPM,610,150);
        } else {
          text("BPM: 0",610,150);
        }
        text("beat interval: " + IBI + " ms",610,210);
  noFill();
    }

    void serialEvent (Serial myPort) {
    // read the string from the serial port.
    String inString = myPort.readStringUntil('\n');

    if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    // convert to an int
    println(inString);
   // int currentHeartrate = int(inString);
      if (inString.charAt(0) == 'S'){          // leading 'S' for sensor data
     inString = inString.substring(1);        // cut off the leading 'S'
     currentHeartrate = int(inString);                // convert the string to usable int
   }
   if (inString.charAt(0) == 'B'){          // leading 'B' for BPM data
     inString = inString.substring(1);        // cut off the leading 'B'
     BPM = int(inString);                   // convert the string to usable int
     beat = true;                         // set beat flag to advance heart rate graph
     //heart = 20;                          // begin heart image 'swell' timer
   }
 if (inString.charAt(0) == 'Q'){            // leading 'Q' means IBI data 
     inString = inString.substring(1);        // cut off the leading 'Q'
     IBI = int(inString);                   // convert the string to usable int
   }
   
   
   
    if (currentHeartrate >= peak){
      peak = currentHeartrate;
    }
    // draw the Heartrate BPM Graph.
    float heartrateHeight = map(currentHeartrate, 0, 1023, 0, height);
    heartanim = heartrateHeight;
    stroke(255,0,0);
   strokeWeight(1);
    line(xPos - 1, height - oldHeartrateHeight, xPos, height - heartrateHeight);
    oldHeartrateHeight = heartrateHeight;
    smooth();
    noStroke();
    // at the edge of the screen, go back to the beginning:
    if (xPos >= 600) {
    xPos = 0;
    background(255);
    grid();
    } else {
    // increment the horizontal position:
    xPos++;
   
    }
    }
    }

