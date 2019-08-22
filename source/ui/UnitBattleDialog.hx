package ui;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import entities.Unit;
import utils.MapUtils;
import utils.Utils;
import utils.data.UnitType;
import states.BattleState;

class UnitBattleDialog extends BattleDialog {

	private var unitName: FlxText;
	private var unitHP: FlxText;
	private var unitFuel: FlxText;
	private var unitAmmo: FlxText;
	private var unitDmg: FlxText;

	private var unitSprite: FlxSprite;
	private var damageDialog: FlxSprite;
	private var iconHP: FlxSprite;
	private var iconFuel: FlxSprite;
	private var iconAmmo: FlxSprite;

	public function new(quadrant: Int) {
		super(36, 60, 36, 4, quadrant);

		createBackground(36, 60, 0xAA444444);

		unitSprite = new FlxSprite(x + 6, y + 10);
		unitSprite.loadGraphic("assets/images/sword-warrior-red.png", true, 20, 20);
		unitSprite.animation.frameIndex = 12;
		add(unitSprite);

		unitName = new FlxText(x, y - 2, 36, "Unit name");
		unitName.alignment = FlxTextAlign.CENTER;
		unitName.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(unitName);

		iconHP = new FlxSprite(x + 4, y + 34);
		iconHP.loadGraphic("assets/images/ui/icon-heart-8.png");
		add(iconHP);

		unitHP = new FlxText(x + 18, y + 28, 16, "10");
		unitHP.alignment = FlxTextAlign.RIGHT;
		unitHP.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(unitHP);

		iconFuel = new FlxSprite(x + 4, y + 42);
		iconFuel.loadGraphic("assets/images/ui/icon-fuel-8.png");
		add(iconFuel);

		unitFuel = new FlxText(x + 18, y + 36, 16, "99");
		unitFuel.alignment = FlxTextAlign.RIGHT;
		unitFuel.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(unitFuel);

		iconAmmo = new FlxSprite(x + 4, y + 51);
		iconAmmo.loadGraphic("assets/images/ui/icon-ammo-8.png");
		add(iconAmmo);

		unitAmmo = new FlxText(x + 18, y + 44, 16, "9");
		unitAmmo.alignment = FlxTextAlign.RIGHT;
		unitAmmo.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(unitAmmo);

		damageDialog = new FlxSprite(x + 2, y - 32);
		damageDialog.loadGraphic("assets/images/ui/damage-dialog.png", false, 32, 32);
		add(damageDialog);

		unitDmg = new FlxText(x + 1, y - 23, 24, "0");
		unitDmg.alignment = FlxTextAlign.CENTER;
		unitDmg.setFormat("assets/fonts/font-pixel-8.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(unitDmg);

		FlxTween.tween(damageDialog, { y: damageDialog.y + 2 }, 0.25, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut });
		FlxTween.tween(unitDmg, { y: unitDmg.y + 2 }, 0.25, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut });

		hideDamageDialog();
	}

	public function setUnit(unit: Unit) {
		unitName.text = unit.unitType.shortName;
		unitSprite.loadGraphic(unit.unitType.gfxPath, true, 24, 24);
		unitSprite.animation.frameIndex = unit.unitType.id * UnitType.unitFrames + unit.player * Unit.spritesheetOffset;
		unitHP.text = Std.string(unit.hp);
		unitFuel.text = Std.string(unit.fuel);

		var found: Bool = false;
		var index: Int = 0;
		while (!found && index < unit.ammo.length) {
			found = unit.ammo[index] >= 0;
			index++;
		}

		if (found) {
			unitAmmo.text = Std.string(unit.ammo[index - 1]);
			iconAmmo.visible = true;
			unitAmmo.visible = true;
		} else {
			iconAmmo.visible = false;
			unitAmmo.visible = false;
		}
	}

	override public function update(elapsed: Float) {
		var indexCoords = MapUtils.coordsToIndex(_map.cursor.pos.x, _map.cursor.pos.y);
		var cursorQuadrant: Int = _map.cursor.getQuadrant();

		if (cursorQuadrant == BattleDialog.QUADRANT_TOP_RIGHT || cursorQuadrant == BattleDialog.QUADRANT_BOTTOM_RIGHT)
			moveToQuadrant(BattleDialog.QUADRANT_BOTTOM_LEFT);

		if (_map.selectedUnit == null)
			hide();

		for (player in _map.players) {
			var unit: Unit = player.getUnitInTile(indexCoords);
			if (_map.selectedUnit == null && unit != null) {
				setUnit(unit);
				show();
			}
		}

		if (cursorQuadrant == BattleDialog.QUADRANT_TOP_LEFT || cursorQuadrant == BattleDialog.QUADRANT_BOTTOM_LEFT)
			restorePosition();

		super.update(elapsed);
	}

	override public function show() {
		visible = true;
	}

	public function setDamage(damage: Int) {
		unitDmg.text = Std.string(Utils.max(0, Utils.min(damage, 100)));
		showDamageDialog();
	}

	public function showDamageDialog() {
		damageDialog.visible = true;
		unitDmg.visible = true;
	}

	public function hideDamageDialog() {
		damageDialog.visible = false;
		unitDmg.visible = false;
	}
}
