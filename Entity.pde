class Entity {
  int x, y;
  float dx, dy;
  byte type;
  int w, h;
  boolean onGround;
  boolean underWater;
  boolean damaged;
  byte maxSpeed = 8; 
  byte facing = 1;
  Entity(int tx, int ty) {
    x = tx;
    y = ty;
    w = 32;
    h = 56;
  }

  void render() {
    if (x+w > offsetX && y+h > offsetY && x < offsetX+width && y < offsetY+height) {
      //draw entity
      noTint();
      if (damaged) {
        tint(255, 100, 100);
      }
      if (type == 0) {
        if (dy < 0 || (dy == 0 && !onGround)) {
          image(charSprites[facing][4], x-offsetX, y-offsetY, w, h);
        } else if (dy > 0) {
          image(charSprites[facing][5], x-offsetX, y-offsetY, w, h);
        } else if (dx == 0) {
          image(charSprites[facing][0], x-offsetX, y-offsetY, w, h);
        } else {
          image(charSprites[facing][(animation*10)%3+1], x-offsetX, y-offsetY, w, h);
        }
      }
    }
  }

  void update() {
    if (up > 0) {
      if (underWater || onGround) {
        if (!underWater && dy == 0) {
          dy = -4;
        }
        if (dy > -7 || !underWater) {
          dy-=0.5;
        }
        if (dy <= -10) {
          onGround = false;
        }
      }
    } else {
      onGround = false;
    }
    if (left > 0) {
      if (onGround && !underWater && dx > -maxSpeed) {
        dx-=2;
      } else if ((underWater && dx > -maxSpeed/2) || !underWater) {
        dx-=0.5;
      }
      facing = 0;
    }
    if (right > 0) {
      if (onGround && !underWater && dx < maxSpeed) {
        dx+=2;
      } else if ((underWater && dx < maxSpeed/2) || !underWater) {
        dx+=0.5;
      }
      facing = 1;
    }
    if ((left <= 0 && right <= 0) || (left > 0 && right > 0)) {
      if (dx > 0) {
        dx-=0.5;
      } else if (dx < 0) {
        dx+=0.5;
      }
      if (dx > 0) {
        dx-=0.5;
      } else if (dx < 0) {
        dx+=0.5;
      }
    }
    if (!onGround && (!underWater || (underWater && up <= 0 && dy < 3))) {
      dy+=0.5;  //gravity
    }

    if (dx > maxSpeed) {
      dx = maxSpeed;
    } else if (dx < -maxSpeed) {
      dx = -maxSpeed;
    }
    if (underWater) {
      onGround = false;
      if (dy > 3) {
        dy-=0.5;
      }
    }

    if (inBounds(x/40, y/40, levels[c].levelWidth, levels[c].levelHeight) && inBounds((x+w)/40, (y+h)/40, levels[c].levelWidth, levels[c].levelHeight)) {
      if (levels[c].tiles[x/40][y/40][1].type == 1 || levels[c].tiles[(x+w)/40][y/40][1].type == 1 || levels[c].tiles[x/40][(y+h)/40][1].type == 1 || levels[c].tiles[(x+w)/40][(y+h)/40][1].type == 1) {
        if (!underWater) {
          for (int i = 0; i < 20; i++) {
            particles.add(new Particle(x+int(random(w)), y+h, int(random(-5, 5)), int(random(-4, 1)), int(random(10, 20)), color(200, 240, int(random(240, 255)), 130)));
          }
        }
        underWater = true;
      } else {
        underWater = false;
      }
    }

    //COLLISIONS
    int tempX, tempY;
    damaged = false;
    if (dx > 0) {      //moving right
      tempX = x+w;
      for (int i = y; i < y+h; i++) {
        for (int j = tempX-w; j <= tempX+dx; j++) {
          if (!inBounds(j/40, i/40, levels[c].levelWidth, levels[c].levelHeight)) {
            //not in the level any more
          } else if (levels[c].tiles[j/40][i/40][1].type >= 2 && levels[c].tiles[j/40][i/40][1].type != 5) {
            if (levels[c].tiles[j/40][i/40][1].type == 6) {
              damaged = true;
            }
            if (dx > j-tempX) {
              dx = j-tempX;
              break;
            }
          }
        }
      }
    } else if (dx < 0) {      //moving left
      tempX = x;
      for (int i = y; i < y+h; i++) {
        for (int j = tempX+w; j >= tempX+dx; j--) {
          if (!inBounds((j-1)/40, i/40, levels[c].levelWidth, levels[c].levelHeight)) {
            //not in the level any more
          } else if (levels[c].tiles[(j-1)/40][i/40][1].type >= 2  && levels[c].tiles[(j-1)/40][i/40][1].type != 5) {
            if (levels[c].tiles[(j-1)/40][i/40][1].type == 6) {
              damaged = true;
            }
            if (dx < j-tempX) {
              dx = j-tempX;
              break;
            }
          }
        }
      }
    }
    x+=dx;
    if (dy > 0) {      //moving down
      tempY = y+h;
      for (int i = x; i < x+w; i++) {
        for (int j = tempY-h; j <= tempY+dy; j++) {
          if (!inBounds(i/40, j/40, levels[c].levelWidth, levels[c].levelHeight)) {
            //not in the level any more
          } else if (levels[c].tiles[i/40][j/40][1].type >= 2 && levels[c].tiles[i/40][j/40][1].type != 5) {
            if (levels[c].tiles[i/40][j/40][1].type == 6) {
              damaged = true;
            }
            if (dy > j-tempY) {
              dy = j-tempY;
              break;
            }
          }
        }
      }
      if (dy == 0) {
        onGround = true;
      } else {
        onGround = false;
      }
    } else if (dy < 0) {      //moving up
      tempY = y;
      for (int i = x; i < x+w; i++) {
        for (int j = tempY+h; j >= tempY+dy; j--) {
          if (!inBounds(i/40, (j-1)/40, levels[c].levelWidth, levels[c].levelHeight)) {
            //not in the level any more
          } else if (levels[c].tiles[i/40][(j-1)/40][1].type >= 2 && levels[c].tiles[i/40][(j-1)/40][1].type != 5) {
            if (levels[c].tiles[i/40][(j-1)/40][1].type == 6) {
              damaged = true;
            }
            if (dy < j-tempY) {
              dy = j-tempY;
              break;
            }
          }
        }
      }
      if (dy == 0 && onGround) {
        onGround = false;
      }
    }
    y+=dy;
  }
}