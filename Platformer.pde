ArrayList<Particle> particles = new ArrayList<Particle>();
float offsetX, offsetY;
Level[] levels = new Level[3];
byte c = 0;
Entity player = new Entity(40, 1184);
boolean up, down, left, right;
PImage[] tileSprites;
PImage[][] joinedSprites;
PImage[][] charSprites;
int animation, time;
int wait = 100;
int playSpeed = 60;


//AI related stuff beyond this point
int topFitness = 0;
int boxRadius = 140;
boolean runningSim = false;
int topMax = 10;
Individual[] topIndividuals = new Individual[topMax];
int topReplay = -1;
Individual replayIndividual;
boolean showNetwork = false;
int currentGen = 0;
int genPopulation = 100;

float mutationChance = 0.1; //float between 0 and 1. 0 = no mutation, 1 is complete

Generation currentGeneration = new Generation(new ArrayList<Individual>());

void setup() {
  size(1000, 600);
  loadImages();
  offsetX = 0;
  offsetY = 0;
  noStroke();
  noSmooth();
  levels[c] = new Level();
  levels[c].loadLevel((byte)c);
  for (int i = 0; i < topMax; i++) {
    topIndividuals[i] = new Individual(new ArrayList<Neuron>());
  }
}

void draw() {
  background(250);
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

    frameRate(playSpeed);

    //AI
    if (runningSim) {
      if (topReplay == -1) {
        if (currentGeneration.update()) {
          currentGeneration = new Generation(new ArrayList<Individual>());  //end of generation, make a new one from the best!
          for (int i = 0; i < genPopulation; i++) {
            int rand1, rand2;
            rand1 = int(random(topMax));
            rand2 = int(random(topMax));
            while (rand1 == rand2) {
              rand2 = int(random(topMax));
            }
            currentGeneration.newChild(topIndividuals[rand1].neurons, topIndividuals[rand2].neurons);
          }
          for (int i = 0; i < genPopulation; i++) {
            currentGeneration.individuals.get(i).mutateNeurons();
          }
          currentGen++;
        }
      } else {
        if (replayIndividual.updateIndividual()) {
          replayIndividual.fitness = 0;
          replayIndividual.fitnessCount = 1;     
          player = new Entity(40, 1184);
        }
      }
    }
  }
  offsetX = player.x - (width - player.w)/2;
  offsetY = player.y - (height - player.h)/2;
  if (offsetX < 40) {
    offsetX = 40;
  }
  if (offsetY < 40) {
    offsetY = 40;
  }
  if (offsetX > levels[c].levelWidth * 40 - width - 40) {
    offsetX = levels[c].levelWidth * 40 - width - 40;
  }
  if (offsetY > levels[c].levelHeight * 40 - height - 40) {
    offsetY = levels[c].levelHeight * 40 - height - 40;
  }
  fill(230);
  rect(width-125, 0, 125, 120);
  fill(0);
  text("FPS: " + int(frameRate), width-120, 15);
  text("Top Fitness: " + topFitness, width-120, 30);
  text("Generation: " + currentGen, width-120, 45);
  text("Individual: " + currentGeneration.currentIndividual, width-120, 60);

  if (runningSim) {
    text("Fitness: " + currentGeneration.individuals.get(currentGeneration.currentIndividual).fitness, width-120, 75);
  }
  if (topReplay >= 0) {
    fill(230);
    rect(0, 0, 130, 23);
    fill(0);
    text("Currently Replaying: " + topReplay, 5, 15);
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
  if (key == 'w' || key == 'W') {
    up = true;
  }
  if (key == 's' || key == 'S') {
    down = true;
  }
  if (key == 'a' || key == 'A') {
    left = true;
  }
  if (key == 'd' || key == 'D') {
    right = true;
  }
}

void keyReleased() {
  if (key == 'w' || key == 'W') {
    up = false;
  }
  if (key == 's' || key == 'S') {
    down = false;
  }
  if (key == 'a' || key == 'A') {
    left = false;
  }
  if (key == 'd' || key == 'D') {
    right = false;
  }
  if (key == ENTER) {
    if (topReplay != -1) {
      topReplay = -1;
      currentGeneration.restartIndividual();
    }
    if (!runningSim) {
      runningSim = true;
      currentGeneration = new Generation(new ArrayList<Individual>());
      for (int i = 0; i < genPopulation; i++) {
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
      player = new Entity(40, 1184);
    }
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    if (playSpeed == 60) {
      showNetwork = !showNetwork;
    }
    playSpeed = 60;
  } else if (mouseButton == RIGHT) {
    if (playSpeed == 10) {
      showNetwork = !showNetwork;
    }
    playSpeed = 10;
  } else if (mouseButton == CENTER) {
    if (playSpeed == 200) {
      showNetwork = !showNetwork;
    }
    playSpeed = 200;
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