/// Generated via spriteBatch.getEnum() function
enum Tex {
  brick("Brick", false),
  bush1("Bush1", false),
  bush2("Bush2", false),
  bush3("Bush3", false),
  castle("Castle", false),
  cloud1("Cloud1", false),
  cloud2("Cloud2", false),
  cloud3("Cloud3", false),
  coin("Coin", false),
  coinUnderground("Coin_Underground", false),
  emptyBlock("EmptyBlock", false),
  flag("Flag", false),
  flagPole("FlagPole", false),
  goombaFlat("Goomba_Flat", false),
  groundBlock("GroundBlock", false),
  hardBlock("HardBlock", false),
  hill1("Hill1", false),
  hill2("Hill2", false),
  koopaShell("Koopa_Shell", false),
  magicMushroom("MagicMushroom", false),
  marioBigIdle("Mario_Big_Idle", false),
  marioBigJump("Mario_Big_Jump", false),
  marioBigSlide("Mario_Big_Slide", false),
  marioSmallDeath("Mario_Small_Death", false),
  marioSmallIdle("Mario_Small_Idle", false),
  marioSmallJump("Mario_Small_Jump", false),
  marioSmallSlide("Mario_Small_Slide", false),
  mysteryBlock("MysteryBlock", false),
  oneUpMushroom("OneUpMushroom", false),
  pipeBottom("PipeBottom", false),
  pipeConnection("PipeConnection", false),
  pipeTop("PipeTop", false),
  starman("Starman", false),
  undergroundBlock("UndergroundBlock", false),
  undergroundBrick("UndergroundBrick", false),

  // Animations
  goombaWalk("Goomba_Walk", true),
  koopaWalk("Koopa_Walk", true),
  marioBigRun("Mario_Big_Run", true),
  marioSmallRun("Mario_Small_Run", true),
  fire("fire", true),
  fireFlower("fire_flower", true),
  starAnim("star_anim", true);

  final String assetName;
  final bool isAnimation;
  const Tex(this.assetName, this.isAnimation);

  @override
  String toString() => assetName;
}
