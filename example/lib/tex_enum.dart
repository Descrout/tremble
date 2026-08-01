/// Generated via spriteBatch.getEnum() function
enum Tex {
  brick("Brick", 1),
  bush1("Bush1", 1),
  bush2("Bush2", 1),
  bush3("Bush3", 1),
  castle("Castle", 1),
  cloud1("Cloud1", 1),
  cloud2("Cloud2", 1),
  cloud3("Cloud3", 1),
  coin("Coin", 1),
  coinUnderground("Coin_Underground", 1),
  emptyBlock("EmptyBlock", 1),
  flag("Flag", 1),
  flagPole("FlagPole", 1),
  goombaFlat("Goomba_Flat", 1),
  groundBlock("GroundBlock", 1),
  hardBlock("HardBlock", 1),
  hill1("Hill1", 1),
  hill2("Hill2", 1),
  koopaShell("Koopa_Shell", 1),
  magicMushroom("MagicMushroom", 1),
  marioBigIdle("Mario_Big_Idle", 1),
  marioBigJump("Mario_Big_Jump", 1),
  marioBigSlide("Mario_Big_Slide", 1),
  marioSmallDeath("Mario_Small_Death", 1),
  marioSmallIdle("Mario_Small_Idle", 1),
  marioSmallJump("Mario_Small_Jump", 1),
  marioSmallSlide("Mario_Small_Slide", 1),
  mysteryBlock("MysteryBlock", 1),
  oneUpMushroom("OneUpMushroom", 1),
  pipeBottom("PipeBottom", 1),
  pipeConnection("PipeConnection", 1),
  pipeTop("PipeTop", 1),
  starman("Starman", 1),
  undergroundBlock("UndergroundBlock", 1),
  undergroundBrick("UndergroundBrick", 1),

  // Animations
  goombaWalk("Goomba_Walk", 2),
  koopaWalk("Koopa_Walk", 2),
  marioBigRun("Mario_Big_Run", 3),
  marioSmallRun("Mario_Small_Run", 3),
  fire("fire", 4),
  fireFlower("fire_flower", 4),
  starAnim("star_anim", 4);

  final String assetName;
  final int frameCount;
  const Tex(this.assetName, this.frameCount);

  @override
  String toString() => assetName;
}
