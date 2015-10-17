class Level {
  Tile[][][] tiles;
  int levelWidth, levelHeight;
  ArrayList<Entity> entities = new ArrayList<Entity>();
  Level() {
    //dont forget to load the level!
    tiles = new Tile[1][1][2];
  }

  void levelRender() {
    background(150, 210, 250);

    for (int i = (int)offsetX/40; i < (offsetX+width)/40; i++) {
      for (int j = (int)offsetY/40; j < (offsetY+height)/40; j++) {
        if (i >= 0 && j >= 0 && i < levelWidth && j < levelHeight) {
          tiles[i][j][0].tileRender();
          tiles[i][j][1].tileRender();
        }
      }
    }
  }

  void saveLevel(byte outputFile) {
    byte temp[] = new byte[levelWidth * levelHeight * 2 + 2];
    temp[0] = byte(levelWidth-128);
    temp[1] = byte(levelHeight-128);
    for (int i = 0; i < levelWidth; i++) {
      for (int j = 0; j < levelHeight; j++) {
        temp[2+(j*levelWidth+i)*2] = tiles[i][j][0].type;
        temp[3+(j*levelWidth+i)*2] = tiles[i][j][1].type;
      }
    }
    saveBytes("tiles" + outputFile + ".dat", temp);
  }

  void loadLevel(byte inputFile) {
    byte temp[] = loadBytes("tiles" + inputFile + ".dat");
    levelWidth = temp[0]+128;
    levelHeight = temp[1]+128;

    tiles = new Tile[levelWidth][levelHeight][2];
    for (int i = 0; i < levelWidth; i++) {
      for (int j = 0; j < levelHeight; j++) {
        tiles[i][j][0] = new Tile(i, j, 0, temp[2+(j*levelWidth+i)*2]);
        tiles[i][j][1] = new Tile(i, j, 1, temp[3+(j*levelWidth+i)*2]);
      }
    }
    for (int i = 0; i < levelWidth; i++) {
      for (int j = 0; j < levelHeight; j++) {
        tiles[i][j][0].getDisplayFlags(levelWidth, levelHeight);
        tiles[i][j][1].getDisplayFlags(levelWidth, levelHeight);
      }
    }
  }
}