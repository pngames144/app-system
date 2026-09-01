class PlayerModel {
  int level;
  int currentExp;
  int expToNextLevel;
  int hp;
  int coins;

  PlayerModel ({
    this.level = 1,
    this.currentExp = 0,
    this.expToNextLevel = 100,
    this.hp = 100, 
    this.coins = 0,
  });
}