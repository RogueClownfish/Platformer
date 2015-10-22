ArrayList<Particle> particles = new ArrayList<Particle>();
float offsetX, offsetY;
Level[] levels = new Level[3];
byte c = 0;
Entity player;
int up, down, left, right;
PImage[] tileSprites;
PImage[][] joinedSprites;
PImage[][] charSprites;
int animation, time;
int wait = 100;
int playSpeed = 60;
int spawnX, spawnY;


//AI related stuff beyond this point
int topFitness = 0;
int boxRadius = 140;
boolean runningSim = false;
int topMax = 10;
Individual[] topIndividuals = new Individual[topMax];
int topReplay = -1;
Individual replayIndividual = new Individual(new ArrayList<Neuron>(), color(0));
;
boolean showNetwork = false;
int currentGen = 0;
int genPopulation = 150;

float mutationChance = 0.4; //float between 0 and 1. 0 = no mutation, 1 is complete

Generation currentGeneration = new Generation(new ArrayList<Individual>());

void setup() {
  size(1000, 600);
  loadImages();
  offsetX = 0;
  offsetY = 0;
  spawnX = 40;
  spawnY = 1184;
  noStroke();
  noSmooth();
  levels[c] = new Level();
  levels[c].loadLevel((byte)c);
  for (int i = 0; i < topMax; i++) {
    topIndividuals[i] = new Individual(new ArrayList<Neuron>(), color(0));
  }
  player = new Entity(spawnX, spawnY);
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
            int rand1;
            rand1 = int(random(topMax));
            while (rand1 == int(i%topMax)) {
              rand1 = int(random(topMax));
            }
            currentGeneration.newChild(cloneNeurons(topIndividuals[int(i%topMax)].neurons), cloneNeurons(topIndividuals[rand1].neurons), topIndividuals[int(i%topMax)].indcolor, topIndividuals[rand1].indcolor);
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
          player = new Entity(spawnX, spawnY);
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
    if (topReplay == -1) {
      text("Fitness: " + currentGeneration.individuals.get(currentGeneration.currentIndividual).fitness, width-120, 75);
    } else {
      text("Fitness: " + topIndividuals[topReplay].fitness, width-120, 75);
    }
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
    up = 1;
  }
  if (key == 's' || key == 'S') {
    down = 1;
  }
  if (key == 'a' || key == 'A') {
    left = 1;
  }
  if (key == 'd' || key == 'D') {
    right = 1;
  }
}

void keyReleased() {
  if (key == 'w' || key == 'W') {
    up = 0;
  }
  if (key == 's' || key == 'S') {
    down = 0;
  }
  if (key == 'a' || key == 'A') {
    left = 0;
  }
  if (key == 'd' || key == 'D') {
    right = 0;
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
      replayIndividual = new Individual(cloneNeurons(topIndividuals[topReplay].neurons), topIndividuals[topReplay].indcolor);
      replayIndividual.fitness = 0;
      replayIndividual.fitnessCount = 2;
      player = new Entity(spawnX, spawnY);
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