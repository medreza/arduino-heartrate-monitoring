// Based on examples from Arduino's Graphing Tutorial and OscP5 documentation
    import processing.serial.*;
    Serial myPort; // The serial port
    int xPos = 1; // horizontal position of the graph
    float oldHeartrateHeight = 0; // for storing the previous reading
    int videoScale = 50;
    int cols, rows;
    int peak = 0;
    int heartanim = 0;
    int BPM;
   
    void setup () {
    // set the window size:
    size(800, 449);
    frameRate(25);
    cols = width/videoScale;
    rows = height/videoScale;
    int runonce = 0;
    // List available serial ports.
    println(Serial.list());

    // Setup which serial port to use.
    // This line might change for different computers.
    myPort = new Serial(this, "COM20", 9600);

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
    }
  }
  
    }

    void draw () {
      // Begin loop for columns
      // DRAW THE HEART AND MAYBE MAKE IT BEAT
  fill(250,0,0);
  stroke(250,0,0);
  // the 'heart' variable is set in serialEvent when arduino sees a beat happen
 float heartanim2 = map(heartanim, 0 ,height, 0, 20);
///heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
  //heart = max(heart,0);       // don't let the heart variable go into negative numbers
  //if (heart > 0){             // if a beat happened recently, 
    //strokeWeight(8);          // make the heart big
  //}
  smooth();   // draw the heart with two bezier curves
  bezier(width-100,50, width-20,-20, width,140, width-100,150);
  bezier(width-100,50, width-190,-20, width-200,140, width-100,150);
  strokeWeight(heartanim2);          // reset the strokeWeight for next time
    }

    void serialEvent (Serial myPort) {
    // read the string from the serial port.
    String inString = myPort.readStringUntil('\n');

    if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    // convert to an int
    println(inString);
    int currentHeartrate = int(inString);
    if (currentHeartrate >= peak){
      peak = currentHeartrate;
    }
    int heartanim = currentHeartrate;
    text("ADC Peak: " + peak,100,420);
    // draw the Heartrate BPM Graph.
    float heartrateHeight = map(currentHeartrate, 325, 475, 0, height);
    stroke(255,0,0);
    //strokeWeight(2);
    line(xPos - 1, height - oldHeartrateHeight, xPos, height - heartrateHeight);
    oldHeartrateHeight = heartrateHeight;
    smooth();
    // at the edge of the screen, go back to the beginning:
    if (xPos >= width) {
    xPos = 0;
    background(255);
    } else {
    // increment the horizontal position:
    xPos++;
   
    }
    }
    }

