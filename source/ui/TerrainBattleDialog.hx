package ui;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.util.FlxColor;

import utils.MapUtils;
import utils.tiled.TiledPropertySet;

import states.BattleState;

class TerrainBattleDialog extends BattleDialog {
	private var terrainName: FlxText;
	private var terrainDef: FlxText;
	private var buildingRes: FlxText;
	private var defIcon: FlxSprite;
	private var resIcon: FlxSprite;
	private var terrainIcon: FlxSprite;

	public function new(quadrant: Int) {
		super(32, 60, 4, 4, quadrant);

		createBackground(32, 60, 0xAA444444);

		terrainIcon = new FlxSprite(x + 8, y - 1);
		terrainIcon.loadGraphic("assets/images/terrain-types.png", true, 16, 32);
		terrainIcon.animation.frameIndex = 0;
		add(terrainIcon);

		terrainName = new FlxText(x, y - 2, 32, "");
		terrainName.alignment = FlxTextAlign.CENTER;
		terrainName.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(terrainName);

		defIcon = new FlxSprite(x + 4, y + 36);
		defIcon.loadGraphic("assets/images/ui/icon-def-11.png", false, 11, 11);
		add(defIcon);

		terrainDef = new FlxText(x + 13, y + 31, 16, "0");
		terrainDef.alignment = FlxTextAlign.RIGHT;
		terrainDef.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(terrainDef);

		resIcon = new FlxSprite(x + 5, y + 47);
		resIcon.loadGraphic("assets/images/ui/icon-building-11.png", false, 11, 11);
		add(resIcon);

		buildingRes = new FlxText(x + 13, y + 43, 16, "0");
		buildingRes.alignment = FlxTextAlign.RIGHT;
		buildingRes.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(buildingRes);
	}

	override public function update(elapsed: Float) {
		setTerrain(MapUtils.pointToIndex(_map.cursor.pos));

		var cursorQuadrant: Int = _map.cursor.getQuadrant();
		if (cursorQuadrant == BattleDialog.QUADRANT_TOP_RIGHT || cursorQuadrant == BattleDialog.QUADRANT_BOTTOM_RIGHT)
			moveToQuadrant(BattleDialog.QUADRANT_BOTTOM_LEFT);
		else
			restorePosition();

		super.update(elapsed);
	}

	override public function loadBackground(path: String, width: Int, height: Int) {
		background = new FlxSprite(bgX, bgY);
		background.loadGraphic(path, width, height);
		add(background);
	}

	public function setTerrain(tileIndex: Int) {
		var building = cast(_map, BattleState).buildings.get(tileIndex);
		var terrainType = MapUtils.getTerrainType(_map, tileIndex);

		if (building != null) {
			terrainName.text = building.buildingType.name;
			terrainDef.text = Std.string(building.buildingType.def);
			buildingRes.text = Std.string(building.res);
			terrainIcon.loadGraphic(building.buildingType.gfxPath, true, 16, 32);
			terrainIcon.animation.frameIndex = building.getFrameIndex();
		} else if (terrainType != null) {
			terrainName.text = terrainType.name;
			terrainDef.text = Std.string(terrainType.def);
			terrainIcon.loadGraphic("assets/images/terrain-types.png", true, 16, 32);
			terrainIcon.animation.frameIndex = terrainType.frameIndex;
		}
	}

	override public function show() {
		visible = true;
	}
}
