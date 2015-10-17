class Generation {
  int id;
  int currentIndividual = 0;
  ArrayList<Individual> individuals = new ArrayList<Individual>();
  Generation(int tid, ArrayList<Individual> tindividuals) {
    id = tid;
    individuals = tindividuals;
  }

  void randomIndividual() {
    individuals.add(new Individual(currentIndividual, id, new ArrayList<Neuron>()));
    for (int i = 0; i < 10; i++) {
      individuals.get(individuals.size()-1).randomNeuron();
      if (int(random(0, 10)) <= i) {
        break;
      }
    }
  }

  void restartIndividual() {
    individuals.get(currentIndividual).fitness = 0;
    individuals.get(currentIndividual).fitnessCount = 1;
    player = new Entity(40, 304);
  }

  void update() {
    if (currentIndividual < individuals.size()-1) {
      if (individuals.get(currentIndividual).updateIndividual()) {
        if (currentIndividual < individuals.size()) {
          int tempfit = individuals.get(currentIndividual).fitness;
          for (int i = 0; i < topMax; i++) { 
            if (tempfit > topIndividuals[i].fitness) {
              for (int j = topMax-1; j > i; j--) {
                topIndividuals[j] = topIndividuals[j-1];
              }
              topIndividuals[i] = individuals.get(currentIndividual);
              break;
            }
          }
          currentIndividual++;
          player = new Entity(40, 304);
        }
      }
    } else {
      runningSim = false;
    }
  }
}


class Individual {
  int id;
  int generationNumber;
  ArrayList<Neuron> neurons = new ArrayList<Neuron>();
  int fitness = 0;
  int fitnessCount = 2;
  Individual(int tid, int generationNumber, ArrayList<Neuron> tneurons) {
    id = tid;
    neurons = tneurons;
  }

  boolean updateIndividual() {
    if (player.x - 40 > fitness) {
      fitness = player.x - 40;
      fitnessCount = 3 + int(fitness/10);
      if (fitness > topFitness) {
        topFitness = fitness;
      }
    } else {
      fitnessCount--;
    }
    if (mousePressed) {
      fill(255, 0, 0, 40);
      noStroke();
      rect(player.x - boxRadius - offsetX, player.y - boxRadius - offsetY, boxRadius * 2, boxRadius * 2);
    }
    up = false;    //check neurons
    right = false;
    left = false;
    for (int i = 0; i <= neurons.size() - 1; i++) {
      switch (neurons.get(i).check()) {
      case 1:
        up = true;
        break;
      case 2:
        right = true;
        break;
      case 3:
        left = true;
        break;
      case -1:
        up = false;
        break;
      case -2:
        right = false;
        break;
      case -3:
        left = false;
        break;
      }
    }
    if (player.damaged || fitnessCount < 0) {
      return true; //if dead
    } else {
      return false;
    }
  }

  void randomNeuron() {
    neurons.add(new Neuron(int(random(-boxRadius, boxRadius)), int(random(-boxRadius, boxRadius)), byte(random(4)), byte(random(1, 4)), boolean(int(random(1.1)))));
  }
}

class Neuron {
  int x, y;
  byte in, out;
  boolean invert; //used to invert signal, if necessary
  Neuron(int tx, int ty, byte tin, byte tout, boolean tinvert) {
    x = tx;
    y = ty;
    in = tin;
    out = tout;
    invert = tinvert;
  }

  byte check() {
    switch (in) {
    case 0:
      fill(255);
      break;
    case 1:
      fill(50, 50, 200);
      break;
    case 2:
      fill(50, 200, 50);
      break;
    case 3:
      fill(200, 50, 50);
      break;
    }
    if (invert) {
      stroke(0);
    }
    boolean check = false;
    if (x <= boxRadius && x >= -boxRadius && y <= boxRadius && y >= -boxRadius && inBounds((player.x + x)/40, (player.y + y)/40, levels[c].levelWidth, levels[c].levelHeight)) {
      switch (levels[c].tiles[(player.x + x)/40][(player.y + y)/40][1].type) {
      case 0:  //air
        if (in == 0) {
          check = true;
        }
        break;
      case 1:  //water
        if (in == 1) {
          check = true;
        }
        break;
      case 2:  //
        if (in == 2) {
          check = true;
        }
        break;
      case 3:  
        if (in == 2) {
          check = true;
        }
        break;
      case 4:
        if (in == 2) {
          check = true;
        }
        break;
      case 5:
        if (in == 0) {
          check = true;
        }
        break;
      case 6:
        if (in == 3) {
          check = true;
        }
        break;
      }
    } else if (in == 0) {
      check = true;
    }
    if (mousePressed) {
      if (out == 1) {
        triangle(player.x + x - offsetX - 4, player.y + y - offsetY, player.x + x - offsetX, player.y + y - offsetY - 4, player.x + x - offsetX + 4, player.y + y - offsetY);
      } else if (out == 2) {
        triangle(player.x + x - offsetX + 4, player.y + y - offsetY, player.x + x - offsetX, player.y + y - offsetY - 4, player.x + x - offsetX, player.y + y - offsetY + 4);
      } else if (out == 3) {
        triangle(player.x + x - offsetX - 4, player.y + y - offsetY, player.x + x - offsetX, player.y + y - offsetY - 4, player.x + x - offsetX, player.y + y - offsetY + 4);
      } else {
        rect(player.x + x - offsetX - 3, player.y + y - offsetY - 3, 6, 6);
      }
    }
    noStroke();
    if ((check && !invert)) {
      return out;
    } else if (check && invert) {
      return byte(-out);
    } else {
      return 0;
    }
  }
}