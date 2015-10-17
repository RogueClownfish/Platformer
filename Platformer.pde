ArrayList<Particle> particles = new ArrayList<Particle>();
float offsetX, offsetY;
Level[] levels = new Level[3];
byte c = 0;
Entity player = new Entity(80, 304);
boolean up, down, left, right;
PImage[] tileSprites;
PImage[][] joinedSprites;
PImage[][] charSprites;
int animation, time;
int wait = 100;

//AI related stuff beyond this point
int topFitness = 0;
int boxRadius = 140;
boolean runningSim = false;
int topMax = 10;
Individual[] topIndividuals = new Individual[topMax];
int topReplay = -1;
Individual replayIndividual;

Generation currentGeneration = new Generation(0, new ArrayList<Individual>());

void setup() {
  size(1000, 600);
  loadImages();
  offsetX = 0;
  offsetY = 0;
  noStroke();
  noSmooth();
  levels[c] = new Level();
  levels[c].loadLevel((byte)c);
  frameRate(60);
  for (int i = 0; i < topMax; i++) {
    topIndividuals[i] = new Individual(0, 0, new ArrayList<Neuron>());
  }
}

void draw() {
  background(250);
  if (mousePressed && mouseButton == RIGHT) {
    frameRate(5);
  } else {
    frameRate(120);
  }
  if (millis() - time >= wait) {
    animation++;
    if (animation > 1000) {
      animation-=1000;
    }
    time = millis();
  }
  if (c < 0) {
    //menu
  } else {

    levels[c].levelRender();
    player.update();
    player.render();
    for (int i = 0; i <= particles.size() - 1; i++) {
      particles.get(i).render();
      if (particles.get(i).update()) {
        particles.remove(i);
      }
    }

    //AI
    if (runningSim) {
      if (topReplay == -1) {
        currentGeneration.update();
      } else {
        if (replayIndividual.updateIndividual()) {
          topReplay = -1;
          currentGeneration.restartIndividual();
        }
      }
    }
    //rect();
  }
  offsetX = player.x - (width - player.w)/2;
  offsetY = player.y - (height - player.h)/2;
  if (offsetX < 40) {
    offsetX = 40;
  }
  if (offsetY < 40) {
    offsetY = 40;
  }
  if (offsetX > levels[c].levelWidth * 40 - width) {
    offsetX = levels[c].levelWidth * 40 - width;
  }
  if (offsetY > levels[c].levelHeight * 40 - height) {
    offsetY = levels[c].levelHeight * 40 - height;
  }
  fill(230);
  rect(width-55, 0, 55, 120);
  fill(0);
  text("FPS: " + int(frameRate), width-50, 15);
  text("dx: " + player.dx, width-50, 30);
  text("dy: " + player.dy, width-50, 45);
  text("tfit: " + topFitness, width-50, 60);
  text("ndvl: " + currentGeneration.currentIndividual, width-50, 75);
  text("rply: " + topReplay, width-50, 90);
  if (runningSim) {
    text("cfit: " + currentGeneration.individuals.get(currentGeneration.currentIndividual).fitness, width-50, 105);
  }
}

boolean inBounds(int x, int y, int lw, int lh) {
  if (x >= 0 && y >= 0 && x < lw && y < lh) {
    return true;
  } else {
    return false;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      up = true;
    }
    if (keyCode == DOWN) {
      down = true;
    }
    if (keyCode == LEFT) {
      left = true;
    }
    if (keyCode == RIGHT) {
      right = true;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) {
      up = false;
    }
    if (keyCode == DOWN) {
      down = false;
    }
    if (keyCode == LEFT) {
      left = false;
    }
    if (keyCode == RIGHT) {
      right = false;
    }
  }
  if (key == ENTER) {
    if (!runningSim) {
      topReplay = -1;
      runningSim = true;
      currentGeneration = new Generation(0, new ArrayList<Individual>());
      for (int i = 0; i < 10000; i++) {
        currentGeneration.randomIndividual();
      }
    }
  }
  if (key >= '0' && key <= '9') {
    if (int(key)-48 < topMax) {
      topReplay = int(key)-48;
      replayIndividual = topIndividuals[topReplay];
      replayIndividual.fitness = 0;
      replayIndividual.fitnessCount = 1;
      player = new Entity(80, 304);
    }
  }
}
void loadImages() {
  PImage tileMap = loadImage("tileMap.png");
  joinedSprites = new PImage[tileMap.height/10][tileMap.width/10];
  for (int i = 0; i < tileMap.height/10; i++) {
    for (int j = 0; j < tileMap.width/10; j++) {
      joinedSprites[i][j] = tileMap.get(j*10, i*10, 10, 10);
    }
  }
  tileMap = loadImage("tiles.png");
  tileSprites = new PImage[tileMap.height/10];
  for (int i = 0; i < tileMap.height/10; i++) {
    tileSprites[i] = tileMap.get(0, i*10, 10, 10);
  }
  PImage charMap = loadImage("char.png");
  charSprites = new PImage[charMap.height/14][charMap.width/8];
  for (int i = 0; i < charMap.height/14; i++) {
    for (int j = 0; j < charMap.width/8; j++) {
      charSprites[i][j] = charMap.get(j*8, i*14, 8, 14);
    }
  }
}