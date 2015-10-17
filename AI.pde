class Generation {
  int currentIndividual = 0;
  ArrayList<Individual> individuals = new ArrayList<Individual>();
  Generation(ArrayList<Individual> tindividuals) {
    individuals = tindividuals;
  }

  void randomIndividual() {
    individuals.add(new Individual(new ArrayList<Neuron>()));
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
    player = new Entity(40, 1184);
  }

  void newChild(ArrayList<Neuron> neurons1, ArrayList<Neuron> neurons2) {
    int neuronCount = (neurons1.size()+neurons2.size())/2 + int(random(abs(neurons1.size()-neurons2.size())));
    ArrayList<Neuron> neuronsOut = new ArrayList<Neuron>();
    for (int i = 0; i < neuronCount; i++) {
      boolean parent = random(1) < 0.5;
      if ((parent || neurons2.size() == 0) && neurons1.size() > 0) {
        neuronsOut.add(neurons1.get(int(random(neurons1.size()))));
      } else {
        neuronsOut.add(neurons2.get(int(random(neurons2.size()))));
      }
    }
    individuals.add(new Individual(neuronsOut));
  }

  boolean update() {
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
          player = new Entity(40, 1184);
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
  Individual(ArrayList<Neuron> tneurons) {
    neurons = tneurons;
  }

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
      fill(255, 0, 0, 40);
      noStroke();
      rect(player.x - boxRadius - offsetX + player.w/2, player.y - boxRadius - offsetY + player.h/2, boxRadius * 2, boxRadius * 2);
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

  void mutateNeurons() {
    for (int i = 0; i < 3; i++) {
      if (random(1) <= mutationChance) {  //add new (random) neuron
        randomNeuron();
      }
    }
    for (int i = 0; i < neurons.size(); i++) {
      if (random(1) <= mutationChance) {  //will mutate this neuron!
        if (random(1) <= mutationChance) {  //move neuron
          neurons.get(i).x += int(random(-40, 40));
          neurons.get(i).y += int(random(-40, 40));
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