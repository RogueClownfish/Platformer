class Tile {
  int x, y, z;
  byte type;
  byte displayFlag;

  Tile(int tx, int ty, int tz, byte ttype) {
    x = tx;
    y = ty;
    z = tz;
    type = ttype;
  }

  void getDisplayFlags(int lw, int lh) {
    displayFlag = 0;
    if (type > 0 && type <= 5) {
      if (inBounds(x+1, y, lw, lh)) {
        if (levels[c].tiles[x+1][y][z].type > 1 && levels[c].tiles[x+1][y][z].type <= 4 || (levels[c].tiles[x+1][y][z].type == type && type != 1)) {
          displayFlag++;
        } else if (levels[c].tiles[x+1][y][z].type == 1) {
          displayFlag+=2;
        }
      }
      if (inBounds(x, y+1, lw, lh)) {
        if (levels[c].tiles[x][y+1][z].type > 1 && levels[c].tiles[x][y+1][z].type <= 4 || (levels[c].tiles[x][y+1][z].type == type && type != 1)) {
          displayFlag+=3;
        } else if (levels[c].tiles[x][y+1][z].type == 1) {
          displayFlag+=6;
        }
      }
      if (inBounds(x-1, y, lw, lh)) {
        if (levels[c].tiles[x-1][y][z].type > 1 && levels[c].tiles[x-1][y][z].type <= 4 || (levels[c].tiles[x-1][y][z].type == type && type != 1)) {
          displayFlag+=9;
        } else if (levels[c].tiles[x-1][y][z].type == 1) {
          displayFlag+=18;
        }
      }
      if (inBounds(x, y-1, lw, lh)) {
        if (levels[c].tiles[x][y-1][z].type > 1 && levels[c].tiles[x][y-1][z].type <= 4 || (levels[c].tiles[x][y-1][z].type == type && type != 1)) {
          displayFlag+=27;
        } else if (levels[c].tiles[x][y-1][z].type == 1) {
          displayFlag+=54;
        }
      }
    }
  }

  void tileRender() {
    if (z == 0) {
      tint(200);
    } else {
      noTint();
    }
    if (type >= 1 && displayFlag > 0) {
      image(joinedSprites[type-1][displayFlag-1], x*40 - offsetX, y*40 - offsetY, 40, 40);
    } else if (type >= 1 && displayFlag == 0) {
      image(tileSprites[type-1], x*40 - offsetX, y*40 - offsetY, 40, 40);
    }
  }
}