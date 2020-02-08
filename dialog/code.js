var font, grammar, yaml, recPrevString, recString;
var chchara, engchara;
var capture;
var w = 640;
var h = 480;
var socket = io();

var backgroundPixels;

var pause = false;

var myVoice = new p5.Speech(); // new P5.Speech object
var myRec = new p5.SpeechRec(); // new P5.SpeechRec object


function startHint(){

  if (!pause) {
    //myVoice.setVoice('Thomas');
  chchara =  ["你想", "要我", "怎样"];
  myVoice.onEnd = startRecSpeech;
  myVoice.speak('Tell me, What do you want? I Will give you the answer soon! Then Leave me alone!');
  //setTimeout(startRecSpeech,5000);
  } 

}

function startRecSpeech(){
  if (!pause) {
    myRec.onEnd = trigerVoice1;
    myRec.start();
    //dspNode.setParamValue("/Loop/LOOP/Volume", -96.0);
    //dspNode.setParamValue("/Loop/LOOP/LoopON", 0);
    //dspNode.setParamValue("/Loop/LOOP/StartRec", 1);
    //setTimeout(trigerVoice1,10000);
  }
}

function playRecSpeech(){
  dspNode.setParamValue("/Loop/LOOP/Volume", -5.0);
  dspNode.setParamValue("/Loop/LOOP/StartRec", 0);
  dspNode.setParamValue("/Loop/LOOP/LoopON", 1);
  setTimeout(trigerVoice1,10000);
}

function trigerVoice1(){
  recString = myRec.resultString;
  console.log(myRec.resultString);
  //dspNode.setParamValue("/Loop/LOOP/Volume", -5.0);
  //dspNode.setParamValue("/Loop/LOOP/StartRec", 0);
  //dspNode.setParamValue("/Loop/LOOP/LoopON", 0);
  sayVoice1();

}

function preload() {

  font = loadFont('../lib/fonts/STXINGKA.otf');
  font2 = loadFont('../lib/fonts/Resagokr.otf');
  yaml = loadStrings('../lib/data/GodSays.yaml');
}

function setup() {

    capture = createCapture({
      audio: false,
      video: {
          width: w,
          height: h
      }
  }, function() {
      console.log('capture ready.')
  });
  capture.elt.setAttribute('playsinline', '');
  capture.size(w, h);
  capture.hide();
  button = createButton('reset');
  button.position( window.innerWidth, 0);
  button.size(50,50);
  button.mousePressed(resetBackground);
 
  socket = io.connect(window.location.hostname + ":5000");
  socket.on("connect", () => {
      socket.emit("connect-client-speech");
      socket.on('dark-mode',
            // When we receive data
            function(data) {
                if (data == 1){
                  setPause();
                } else {
                  setResume();
                }
            }
        );
      socket.on('reset-bg',
        // When we receive data
        function() {
          //console.log("resetbg");
          resetBackground();
        }
    );
  });

  createCanvas(window.innerWidth,window.innerHeight);
  //textFont(font, 50);
  textAlign(CENTER);
  grammar = new RiGrammar(yaml.join('\n'));
  engchara = ["Dit moi", "What do you want?", "Sinon, Cache Moi!"];
  chchara =  ["你想", "要我", "怎样"];
  recString = "";

  
  //myVoice.listVoices();
  myVoice.interrupt=true;
  myVoice.setRate(0.8);

  //startHint();
  //setPause();
}

function verticalText(input, x, y) {
  var output = "";  // create an empty string
 
  for (var i = 0; i < input.length; i += 1) {
    output += input.charAt(i) + "\n"; // add each character with a line break in between
  }
 
  push(); // use push and pop to restore style (in this case the change in textAlign) after displaing the text 
  textAlign(CENTER, TOP); // center the characters horizontaly with CENTER and display them under the provided y with TOP
  text(output, x, y); // display the text
  pop();
}

function draw() {

  //background(255,0);
  if (!pause) {
  background(255,50);
  //fill(250)
  textFont(font, 0);
    verticalText(chchara[0], width / 2 - 150, 400+80);
    verticalText(chchara[1], width / 2 , 400+135);
    verticalText(chchara[2], width / 2 + 150, 400+80);
  textFont(font2, 70);
    text("Tell me, What do you want?", width / 2, 145);
    text("I Will give you the answer soon!", width / 2, 205);
    text("Then Leave me alone!", width / 2, 265);
 
    //text(myRec.resultString, width / 2, 590);
  } else {
    background(255,50);
  }
  
/*
  capture.loadPixels();
    if (capture.pixels.length > 0) { // don't forget this!
        var total = 0;
        var i = 0;
        for (var y = 0; y < h; y++) {
            for (var x = 0; x < w; x++) {
                var redValue = capture.pixels[i];
                total += redValue;
                i += 4;
            }
        }
        var n = w * h;
        var avg = int(total / n);
        socket.emit('brightness', avg);
    }
*/
capture.loadPixels();
    if (capture.pixels.length > 0) { // don't forget this!
        if (!backgroundPixels) {
            backgroundPixels = copyImage(capture.pixels, backgroundPixels);
        }
        var i = 0;
        var pixels = capture.pixels;
        var thresholdAmount = 25 * 255. / 100.;
        
            var total = 0;
            for (var y = 0; y < h; y++) {
                for (var x = 0; x < w; x++) {
                    // another common type of background thresholding uses absolute difference, like this:
                    // var total = Math.abs(pixels[i+0] - backgroundPixels[i+0] > thresholdAmount) || ...
                    var rdiff = Math.abs(pixels[i + 0] - backgroundPixels[i + 0]) > thresholdAmount;
                    var gdiff = Math.abs(pixels[i + 1] - backgroundPixels[i + 1]) > thresholdAmount;
                    var bdiff = Math.abs(pixels[i + 2] - backgroundPixels[i + 2]) > thresholdAmount;
                    var anydiff = rdiff || gdiff || bdiff;
                    var output = 0;
                    if (anydiff) {
                        output = 255;
                        total++;
                    }
                    pixels[i++] = output;
                    pixels[i++] = output;
                    pixels[i++] = output;
                    i++; // skip alpha
                }
            }
            var n = w * h;
            var ratio = total / n;
            //select('#presence').elt.innerText = int(100 * ratio) + '%';
            socket.emit('presence', int(100 * ratio));
            console.log(int(100 * ratio));
        
    }
    capture.updatePixels();
    //image(capture, 0, 0, 640, 480);
}

function sayVoice1() {

  if (!pause){
    //if (myRec.resultValue ) {
      var result = grammar.expand();
      var lines = result.split("%");
      for (var j=0;j<engchara.length;j++)
      {
        var line=lines[j].split("#");
        chchara[j]=line[0];
        engchara[j]=line[1];
      }
  
      //myVoice.setVoice(Math.floor(random(myVoice.voices.length)));
      myVoice.onEnd = startHint;
      myVoice.speak(engchara);
      recPrevString = myRec.resultString;
      //setTimeout(startHint,10000);
    //} else {
      //startHint();
    //}
  }
  

}

function setPause() {
  if(pause == false){
    pause= true;
    myRec.onEnd = null;
    myVoice.cancel();
    //resetBackground();
  }
}

function setResume() {
  if(pause == true){
    pause= false;
    startHint();
  }
  
}


function resetBackground() {
  backgroundPixels = undefined;
}


function copyImage(src, dst) {
  var n = src.length;
  if (!dst || dst.length != n) {
      dst = new src.constructor(n);
  }
  while (n--) {
      dst[n] = src[n];
  }
  return dst;
}