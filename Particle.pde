class Particle {    //the particle class
  int x;
  int y;
  float dx; 
  float dy; 
  int size;
  color pColor;

  Particle(int tempx, int tempy, int tempdx, int tempdy, int tempsize, color tempc) {
    x = tempx;
    y = tempy;
    dy = tempdy;
    dx = tempdx;
    size = tempsize;
    pColor = tempc;
  }

  boolean update() {      //moves the particle
    dy+=0.5;
    int tempX, tempY;
    if (dx > 0) {      //moving right
      tempX = x;
      for (int j = tempX; j <= tempX+dx; j++) {
        if (!inBounds(j/40, y/40, levels[c].levelWidth, levels[c].levelHeight)) {
          //not in the level any more
        } else if (levels[c].tiles[j/40][y/40][1].type >= 2) {
          if (dx > j-tempX) {
            dx = j-tempX;
            break;
          }
        }
      }
    } else if (dx < 0) {      //moving left
      tempX = x;
      for (int j = tempX; j >= tempX+dx; j--) {
        if (!inBounds((j-1)/40, y/40, levels[c].levelWidth, levels[c].levelHeight)) {
          //not in the level any more
        } else if (levels[c].tiles[(j-1)/40][y/40][1].type >= 2) {
          if (dx < j-tempX) {
            dx = j-tempX;
            break;
          }
        }
      }
    }
    x+=dx;
    if (dy > 0) {      //moving down
      tempY = y;
      for (int j = tempY; j <= tempY+dy; j++) {
        if (!inBounds(x/40, j/40, levels[c].levelWidth, levels[c].levelHeight)) {
          //not in the level any more
        } else if (levels[c].tiles[x/40][j/40][1].type >= 2) {
          if (dy > j-tempY) {
            dy = j-tempY;
            break;
          }
        }
      }
    } else if (dy < 0) {      //moving up
      tempY = y;
      for (int j = tempY; j >= tempY+dy; j--) {
        if (!inBounds(x/40, (j-1)/40, levels[c].levelWidth, levels[c].levelHeight)) {
          //not in the level any more
        } else if (levels[c].tiles[x/40][(j-1)/40][1].type >= 2) {
          if (dy < j-tempY) {
            dy = j-tempY;
            break;
          }
        }
      }
    }
    y+=dy;
    size--;
    if (size <= 0) {
      return true;
    }
    return false;
  }

  void render() {      //draws the particle
    noStroke();
    fill(pColor);
    rect(x-offsetX, y-offsetY, 4, 4);
  }
}