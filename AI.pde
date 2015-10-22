class Generation {
  int currentIndividual = 0;
  ArrayList<Individual> individuals = new ArrayList<Individual>();
  Generation(ArrayList<Individual> tindividuals) {
    individuals = tindividuals;
  }
  //Generates a candidate
  void randomIndividual() {
    individuals.add(new Individual(new ArrayList<Neuron>(), color(random(225), random(225), random(225))));
    for (int i = 0; i < 10; i++) {
      individuals.get(individuals.size()-1).randomNeuron();
      if (int(random(0, 10)) <= i) {
        break;
      }
    }
  }
  //??? is this for replays? or when to kill the candidate?
  void restartIndividual() {
    individuals.get(currentIndividual).fitness = 0;
    individuals.get(currentIndividual).fitnessCount = 1;
    player = new Entity(spawnX, spawnY);
  }
  //Breeding a new generation
  void newChild(ArrayList<Neuron> neurons1, ArrayList<Neuron> neurons2, color color1, color color2) {
    int neuronCount = (neurons1.size()+neurons2.size())/2 + int(random(abs(neurons1.size()-neurons2.size())));
    ArrayList<Neuron> neuronsOut = new ArrayList<Neuron>();
    for (int i = 0; i < neuronCount; i++) {
      boolean parent = random(1) < 0.5;
      if (parent) {
        if (neurons1.size() > 0) {
          neuronsOut.add(cloneNeuron(neurons1.get(int(random(neurons1.size())))));
        } else {
          neuronsOut.add(new Neuron(int(random(-boxRadius, boxRadius)), int(random(-boxRadius, boxRadius)), byte(random(4)), byte(random(1, 4)), random(1) < 0.4));
        }
      } else {
        if (neurons2.size() > 0) {
          neuronsOut.add(cloneNeuron(neurons2.get(int(random(neurons2.size())))));
        } else {
          neuronsOut.add(new Neuron(int(random(-boxRadius, boxRadius)), int(random(-boxRadius, boxRadius)), byte(random(4)), byte(random(1, 4)), random(1) < 0.4));
        }
      }
    }
    individuals.add(new Individual(neuronsOut, color(red(color1)+red(color2)/2, green(color1)+green(color2)/2, blue(color1)+blue(color2)/2)));
  }

  boolean update() {
    if (currentIndividual < individuals.size()-1) {
      if (individuals.get(currentIndividual).updateIndividual()) {
        if (currentIndividual < individuals.size()) {
          int tempfit = individuals.get(currentIndividual).fitness;
          for (int i = 0; i < topMax; i++) { 
            if (tempfit > topIndividuals[i].fitness) {  //put into top 10 or whatever
              for (int j = topMax-1; j > i; j--) {
                topIndividuals[j] = new Individual(cloneNeurons(topIndividuals[j-1].neurons), topIndividuals[j-1].indcolor);
                topIndividuals[j].fitness = topIndividuals[j-1].fitness;
              }
              topIndividuals[i] = new Individual(cloneNeurons(individuals.get(currentIndividual).neurons), individuals.get(currentIndividual).indcolor);
              topIndividuals[i].fitness = individuals.get(currentIndividual).fitness;
              break;
            }
          }
          println();
          for (int j = 0; j < topMax; j++) {
            println(topIndividuals[j].fitness);
          }
          currentIndividual++;
          player = new Entity(spawnX, spawnY);
        } else {
          return true;
        }
      }
    } else {
      return true;
    }
    return false;
  }
}


class Individual {
  ArrayList<Neuron> neurons = new ArrayList<Neuron>();
  int fitness = 0;
  int fitnessCount = 2;
  color indcolor;
  Individual(ArrayList<Neuron> tneurons, color tcolor) {
    neurons = tneurons;
    indcolor = tcolor;
  }
  //individaul display stuff
  boolean updateIndividual() {
    if (player.x - 40 > fitness) {
      fitness = player.x - 40;
      fitnessCount = 3 + int(fitness/20);
      if (fitness > topFitness) {
        topFitness = fitness;
      }
    } else {
      fitnessCount--;
    }
    if (showNetwork) {
      fill(indcolor, 100);
      stroke(0, 50);
      rect(player.x - boxRadius - offsetX + player.w/2, player.y - boxRadius - offsetY + player.h/2, boxRadius * 2, boxRadius * 2);
    }
    up = 0;    //check neurons
    right = 0;
    left = 0;
    for (int i = 0; i <= neurons.size() - 1; i++) {
      switch (neurons.get(i).check()) {
      case 1:
        up++;
        break;
      case 2:
        right++;
        break;
      case 3:
        left++;
        break;
      case -1:
        up--;
        break;
      case -2:
        right--;
        break;
      case -3:
        left--;
        break;
      }
    }
    if (player.damaged || fitnessCount < 0) {
      return true; //if dead
    } else {
      return false;
    }
  }
  //duh
  void mutateNeurons() {
    for (int i = 0; i < 3; i++) {
      if (random(1) <= mutationChance) {  //add new (random) neuron
        randomNeuron();
      }
    }
    for (int i = 0; i < neurons.size(); i++) {
      if (random(1) <= mutationChance) {  //will mutate this neuron!
        if (random(1) <= mutationChance) {  //move neuron
          neurons.get(i).x += int(random(-80, 80));
          neurons.get(i).y += int(random(-80, 80));
          if (neurons.get(i).x < -boxRadius) {
            neurons.get(i).x = -boxRadius;
          } else if (neurons.get(i).x > boxRadius) {
            neurons.get(i).x = boxRadius;
          }
          if (neurons.get(i).y < -boxRadius) {
            neurons.get(i).y = -boxRadius;
          } else if (neurons.get(i).y > boxRadius) {
            neurons.get(i).y = boxRadius;
          }
        }
        if (random(1) <= mutationChance) {  //invert neuron
          neurons.get(i).invert = !neurons.get(i).invert;
        }
        if (random(1) <= mutationChance) {  //change neuron input
          neurons.get(i).in = byte(random(4));
        }
        if (random(1) <= mutationChance) {  //change neuron output
          neurons.get(i).out = byte(random(1, 4));
        }
        if (random(1) <= mutationChance/2 && i > 1) {  //KILL NEURON (smaller chance)
          neurons.remove(i);
        }
      }
    }
  }
  //duh #2
  void randomNeuron() {
    neurons.add(new Neuron(int(random(-boxRadius, boxRadius)), int(random(-boxRadius, boxRadius)), byte(random(4)), byte(random(1, 4)), random(1) < 0.4));
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
  //Block detection for neurons
  byte check() {
    switch (in) {
    case 0:
      fill(255);
      break;
    case 1:
      fill(0, 0, 255);
      break;
    case 2:
      fill(0, 255, 0);
      break;
    case 3:
      fill(255, 0, 0);
      break;
    }
    if (invert) {
      stroke(0);
    } else {
      noStroke();
    }
    boolean check = false;
    if (x <= boxRadius && x >= -boxRadius && y <= boxRadius && y >= -boxRadius && inBounds((player.x + x + player.w/2)/40, (player.y + y + player.h/2)/40, levels[c].levelWidth, levels[c].levelHeight)) {
      switch (levels[c].tiles[(player.x + x + player.w/2)/40][(player.y + y + player.h/2)/40][1].type) {
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
    if (showNetwork) {
      if (out == 1) {
        triangle(player.x + x - offsetX - 4 + player.w/2, player.y + y - offsetY + player.h/2, player.x + x - offsetX + player.w/2, player.y + y - offsetY - 4 + player.h/2, player.x + x - offsetX + 4 + player.w/2, player.y + y - offsetY + player.h/2);
      } else if (out == 2) {
        triangle(player.x + x - offsetX + 4 + player.w/2, player.y + y - offsetY + player.h/2, player.x + x - offsetX + player.w/2, player.y + y - offsetY - 4 + player.h/2, player.x + x - offsetX + player.w/2, player.y + y - offsetY + 4 + player.h/2);
      } else if (out == 3) {
        triangle(player.x + x - offsetX - 4 + player.w/2, player.y + y - offsetY + player.h/2, player.x + x - offsetX + player.w/2, player.y + y - offsetY - 4 + player.h/2, player.x + x - offsetX + player.w/2, player.y + y - offsetY + 4 + player.h/2);
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
//??
ArrayList<Neuron> cloneNeurons(ArrayList<Neuron> neuronsIn) {
  ArrayList<Neuron> neuronsOut = new ArrayList<Neuron>();
  for (int i = 0; i < neuronsIn.size() - 1; i++) {
    neuronsOut.add(new Neuron(neuronsIn.get(i).x, neuronsIn.get(i).y, neuronsIn.get(i).in, neuronsIn.get(i).out, neuronsIn.get(i).invert));
  }
  return neuronsIn;
}
//For breeding a new generation
Neuron cloneNeuron(Neuron neuronIn) {
  return new Neuron(neuronIn.x, neuronIn.y, neuronIn.in, neuronIn.out, neuronIn.invert);
}