package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import utils.Utils;
import utils.KeyboardUtils;
import utils.Data;
import utils.data.UnitType;

import entities.Building;
import entities.Unit;

import states.BattleState;

class UnitDeploymentDialog extends BattleDialog {

	private var unitNames: Array<FlxText>;
	private var unitCosts: Array<FlxText>;
	private var unitSprites: Array<FlxSprite>;
	private var cursor: FlxSprite;
	private var hintUp: FlxSprite;
	private var hintDown: FlxSprite;

	private static var lineHeight = 18;
	private static var nameWidth = 44;
	private static var costWidth = 46;
	private static var marginTop = 2;
	private static var labelMarginTop = 2;
	private static var spriteWidth = 20;
	private static var unitMarginLeft = 10;
	private static var unitMarginTop = -1;
	private static var cursorMarginLeft = -4;
	private static var cursorMarginTop = 6;
	private static var hintMarginTop = -4;

	private static var unitsPerPage = 6;

	private static var textShadow: FlxColor = 0xFFEEEEEE;

	private var data: Data;
	private var totalUnits: Int;
	private var selectedPos: Int;	// Highlighted position
	private var viewPos: Int;		// First visible position
	private var building: Building;
	private var keyboard: KeyboardUtils;

	public function new() {
		var width = 126;
		var height = 120;
		var margin = 4;
		path = "assets/images/ui/dialog-unit-deployment";

		super(width, height, margin, margin, BattleDialog.QUADRANT_BOTTOM_LEFT);

		visible = false;
		data = Data.getInstance();
		unitNames = new Array<FlxText>();
		unitCosts = new Array<FlxText>();
		unitSprites = new Array<FlxSprite>();
		keyboard = KeyboardUtils.getInstance();

		updateBackground();

		cursor = new FlxSprite(bgX + cursorMarginLeft, bgY + cursorMarginTop);
		cursor.loadGraphic("assets/images/ui/arrow.png", true, 18, 18);
		cursor.animation.add("idle", [0, 1], 3);
		cursor.animation.play("idle");
		add(cursor);

		hintUp = new FlxSprite(bgX + width / 2, bgY + hintMarginTop);
		hintUp.loadGraphic("assets/images/ui/arrow-dir.png", true, 12, 12);
		hintUp.animation.add("idle", [0, 1], 3);
		hintUp.animation.play("idle");
		add(hintUp);

		hintDown = new FlxSprite(bgX + width / 2, bgY + height + 2 * hintMarginTop);
		hintDown.loadGraphic("assets/images/ui/arrow-dir.png", true, 12, 12);
		hintDown.animation.add("idle", [4, 5], 3);
		hintDown.animation.play("idle");
		add(hintDown);
	}

	public function setBuilding(building: Building) {
		this.building = building;

		Utils.clearTextArray(unitNames);
		Utils.clearTextArray(unitCosts);
		Utils.clearSpriteArray(unitSprites);

		totalUnits = building.buildingType.units.length;

		var player = cast(_map, BattleState).getCurrentPlayer();

		for (i in 0 ... totalUnits) {
			var unit: UnitType = data.units.get(building.buildingType.units[i].unit);
			var unitCost: Int = building.buildingType.units[i].cost;

			var animFrames: Array<Int> = Unit.changeAnimColour(unit.animIdle, player.id);
			var unitSprite: FlxSprite = new FlxSprite(0, 0);
			unitSprite.loadGraphic(unit.gfxPath, true, 24, 24);
			unitSprite.animation.add("idle", animFrames, 2, true);
			unitSprite.animation.play("idle");
			unitSprites.push(unitSprite);
			add(unitSprite);

			var unitName = new FlxText(0, 0, costWidth, unit.name);
			unitName.setFormat("assets/fonts/font-pixel-8.ttf", 16, FlxColor.BLACK, FlxTextBorderStyle.SHADOW, textShadow);
			unitNames.push(unitName);
			add(unitName);

			var unitCostTxt = new FlxText(0, 0, costWidth, Std.string(unitCost));
			unitCostTxt.setFormat("assets/fonts/font-pixel-8.ttf", 16, FlxColor.BLACK, FlxTextAlign.RIGHT, FlxTextBorderStyle.SHADOW, textShadow);
			unitCosts.push(unitCostTxt);
			add(unitCostTxt);

			if (player.funds < unitCost) {
				unitSprite.color = Unit.colourDisabled;
			}
		}

		selectedPos = 0;
		viewPos = 0;
		refresh();
	}

	public function nextItem() {
		if (selectedPos < totalUnits - 1) {
			selectedPos++;

			if (selectedPos >= viewPos + unitsPerPage) {
				viewPos++;
			}

			refresh();
		}
	}

	public function prevItem() {
		if (selectedPos > 0) {
			selectedPos--;

			if (selectedPos < viewPos) {
				viewPos--;
			}

			refresh();
		}
	}

	private function refresh() {
		for (i in 0 ... totalUnits) {
			unitSprites[i].visible = false;
			unitNames[i].visible = false;
			unitCosts[i].visible = false;
		}

		var index: Int = 0;
		var lastPos: Int = Utils.min(viewPos + unitsPerPage, unitSprites.length);
		for (i in viewPos ... lastPos) {
			unitSprites[i].visible = true;
			unitNames[i].visible = true;
			unitCosts[i].visible = true;

			unitSprites[i].x = bgX + unitMarginLeft;
			unitSprites[i].y = bgY + marginTop + unitMarginTop + index * lineHeight;
			unitNames[i].x = bgX + unitMarginLeft + spriteWidth;
			unitNames[i].y = bgY + marginTop + labelMarginTop + index * lineHeight;
			unitCosts[i].x = bgX + unitMarginLeft + spriteWidth + nameWidth;
			unitCosts[i].y = bgY + marginTop + labelMarginTop + index * lineHeight;

			index++;
		}

		hintUp.visible = viewPos > 0;
		hintDown.visible = viewPos + unitsPerPage < totalUnits;

		index = selectedPos - viewPos;
		cursor.y = bgY + cursorMarginTop + index * lineHeight;
	}

	public function deploy() {
		building.deployUnit(building.buildingType.units[selectedPos].unit);
	}

	override public function update(elapsed: Float) {
		var up: Bool = keyboard.isPressed(KeyboardUtils.KEY_UP);
		var down: Bool = keyboard.isPressed(KeyboardUtils.KEY_DOWN);

		if (visible && up) {
			prevItem();
		} else if (visible && down) {
			nextItem();
		}

		super.update(elapsed);
	}
}
