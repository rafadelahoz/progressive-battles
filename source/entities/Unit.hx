package entities;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import haxe.Timer;

import utils.MapUtils;
import utils.MapUtils.Path;
import utils.Utils;
import utils.data.UnitType;

import entities.Item;
import entities.Weapon;
import utils.data.TilePoint;

import ui.ProgressBar;

import states.BattleState;

class Unit extends Entity {

	public static var colourDisabled: Int = 0x555555;
	public static var spritesheetOffset: Int = 256;
	public static var marginLeftHpIndicator: Int = 12;
	public static var marginTopHpIndicator: Int = 13;
	public static var marginLeftActionIcon: Int = 4;
	public static var marginTopActionIcon: Int = 13;

	public var cs: UnitStats;	// current stats
	public var os: UnitStats;	// original stats

	public var hpIndicator: FlxSprite;
	private var actionIcon: FlxSprite;	// Transport, Capture...

	public var hp: Int;
	public var fuel: Int;
	public var ammo: Array<Int>;

	public var lvl: Int;
	public var exp: Int;

	public var pos: TilePoint;
	public var offsetX: Int;	// horizontal offset from the upper left corner of the tile
	public var offsetY: Int;	// vertical offset from the upper left corner of the tile

	public var atkRangeMin: Int;
	public var atkRangeMax: Int;
	public var defenseBonus: Int;
	public var avoidBonus: Int;

	public var name: String;
	public var type: String;
	public var unitType: UnitType;

	public var status: UnitStatus;
	public var movementType: UnitMovementType;

	public var items: Array<Item>;
	public var equippedWeapon: Weapon;

	public var activePath: Path;

	public var player: Int;
	public var battle: BattleState;

	public function new(posX: Int, posY: Int, unitType: UnitType, player: Int) {
		offsetX = -4;
		offsetY = -8;
		this.player = player;

		super(posX * ViewPort.tileSize + offsetX, posY * ViewPort.tileSize + offsetY);
		sprite.loadGraphic(unitType.gfxPath, true, 24, 24);

		sprite.setFacingFlip(FlxObject.LEFT, true, false);
		sprite.setFacingFlip(FlxObject.RIGHT, false, false);

		var animIdle = changeAnimColour(unitType.animIdle, player);
		var animWalkDown = changeAnimColour(unitType.animWalkDown, player);
		var animWalkUp = changeAnimColour(unitType.animWalkUp, player);
		var animWalkLR = changeAnimColour(unitType.animWalkLR, player);

		sprite.animation.add("idle", animIdle, 2, true);
		sprite.animation.add("walk-down", animWalkDown, 6, true);
		sprite.animation.add("walk-lr", animWalkLR, 6, true);
		sprite.animation.add("walk-up", animWalkUp, 6, true);
		sprite.animation.add("selected", animWalkLR, 6, true);

		hpIndicator = new FlxSprite(sprite.x + marginLeftHpIndicator, sprite.y + marginTopHpIndicator);
		hpIndicator.loadGraphic("assets/images/ui/icon-hp-8.png", true, 8, 8);
		hpIndicator.visible = false;
		add(hpIndicator);

		this.unitType = unitType;
		name = unitType.name;

		cs = new UnitStats();
		os = new UnitStats();

		hp = 10;
		fuel = unitType.fuel;
		ammo = new Array<Int>();
		atkRangeMin = 99;
		atkRangeMax = 0;

		for (weaponType in unitType.weapons) {
			ammo.push(weaponType.ammo);
			atkRangeMin = Utils.min(atkRangeMin, weaponType.rangeMin);
			atkRangeMax = Utils.max(atkRangeMax, weaponType.rangeMax);
		}

		os.mov = unitType.mov;
		resetStats();

		pos = new TilePoint(posX, posY);

		defenseBonus = 0;
		avoidBonus = 0;

		items = new Array<Item>();
		equippedWeapon = null;

		enable();
		movementType = UnitMovementType.ONFOOT;

		battle = BattleState.getInstance();
	}

	public function useItem(item: Item) {
		if (Weapon.isWeapon(item)) {
			equipWeapon(cast(item, Weapon));
		} else {
			trace(item.name + " is an item");
		}
	}

	public function equipWeapon(weapon: Weapon) {
		if (equippedWeapon != null)
			equippedWeapon.setEquipped(false);

		equippedWeapon = weapon;
		atkRangeMin = weapon.minRange;
		atkRangeMax = weapon.maxRange;

		var index: Int = items.indexOf(weapon);
		if (index >= 0) {
			items.splice(index, 1);
			items.insert(0, weapon);
			weapon.setEquipped(true);
		}
	}

	public function select(): Bool {
		if (status == UnitStatus.STATUS_AVAILABLE || status == UnitStatus.STATUS_MOVED) {
			sprite.animation.play("selected");
			status = UnitStatus.STATUS_SELECTED;
			return true;
		}
		return false;
	}

	public function deselect() {
		if (status == UnitStatus.STATUS_SELECTED) {
			sprite.animation.play("idle");
			status = UnitStatus.STATUS_AVAILABLE;
		}
	}

	public function enable() {
		sprite.animation.play("idle");
		status = UnitStatus.STATUS_AVAILABLE;
		sprite.color = 0xffffff;
	}

	public function disable() {
		sprite.animation.play("idle");
		status = UnitStatus.STATUS_DONE;
		sprite.color = colourDisabled;
	}

	public function onWait() {
		disable();
	}

	public function placeUnit(posX: Int, posY: Int) {
		sprite.x = posX * ViewPort.tileSize + offsetX;
		sprite.y = posY * ViewPort.tileSize + offsetY;

		pos.x = posX;
		pos.y = posY;

		moveElems(posX, posY);
	}

	public function moveUnit(posX: Int, posY: Int, path: Path, callback: FlxPath -> Void = null) {
		if (path != null) {
			status = UnitStatus.STATUS_MOVING;
			fuel -= path.cost;

			if (actionIcon != null && (posX != pos.x || posY != pos.y))
				setActionIconVisible(false);

			if (activePath != null)
				activePath.destroy();

			activePath = path;

			if (sprite.path != null) {
				for (step in sprite.path.nodes)
					step.destroy();
			}

			var pathArray = new Array<FlxPoint>();
			for (step in path.path)
				pathArray.push(new FlxPoint(step.x * ViewPort.tileSize + ViewPort.tileSize / 2,
					step.y * ViewPort.tileSize + (ViewPort.tileSize + offsetY) / 2));

			sprite.path = new FlxPath(pathArray);

			if (callback != null)
				sprite.path.onComplete = callback;
			else
				moveElems(posX, posY);

			sprite.animation.play("walk-lr");
			sprite.path.start(200);

			for (step in pathArray)
				step.destroy();

		} else {	// Cancelling movement
			sprite.x = posX * ViewPort.tileSize + offsetX;
			sprite.y = posY * ViewPort.tileSize + offsetY;
			fuel += activePath.cost;
			moveElems(pos.x, posY);

			if (actionIcon != null)
				setActionIconVisible(true);

			if (callback != null)
				callback(null);
		}

		pos.x = posX;
		pos.y = posY;
	}

	public function moveElems(posX: Int, posY: Int) {
		hpIndicator.x = sprite.x + marginLeftHpIndicator;
		hpIndicator.y = sprite.y + marginTopHpIndicator;

		if (actionIcon != null) {
			actionIcon.x = sprite.x + marginLeftActionIcon;
			actionIcon.y = sprite.y + marginTopActionIcon;
		}
	}

	override public function update(elapsed: Float) {
		if (status == UnitStatus.STATUS_MOVING) {
			var nodeIndex = sprite.path.nodeIndex;
			var changedFacing = false;

			if (nodeIndex > 0 && nodeIndex < activePath.path.length) {
				if (sprite.facing != activePath.facing[nodeIndex - 1]) {
					sprite.facing = activePath.facing[nodeIndex - 1];
					changedFacing = true;
				}
			} else if (nodeIndex == 0) {
				sprite.facing = activePath.facing[nodeIndex];
				changedFacing = true;
			}

			if (changedFacing && (sprite.facing == FlxObject.LEFT || sprite.facing == FlxObject.RIGHT)) {
				sprite.animation.play("walk-lr");
			} else if (changedFacing && sprite.facing == FlxObject.UP) {
				sprite.animation.play("walk-up");
			} else if (changedFacing && sprite.facing == FlxObject.DOWN) {
				sprite.animation.play("walk-down");
			}
		}

		hpIndicator.visible = status != STATUS_SELECTED && status != STATUS_MOVING &&
			status != STATUS_MOVED && hp < 10;
		if (hpIndicator.visible) {
			hpIndicator.animation.frameIndex = hp;
		}

		super.update(elapsed);
	}

	/*public function getPhysicalPower(enemy: Unit): Int {
		// Physical Attack = Strength + (Weapon Might + Weapon Triangle Bonus) X Weapon effectiveness + Support Bonus
		var physicalPower: Int = cs.str;
		var weaponBonus: Int = 0;

		if (equippedWeapon != null) {
			weaponBonus += equippedWeapon.might;
		}

		if (enemy.equippedWeapon != null) {
			weaponBonus += Weapon.getDamageBonus(equippedWeapon, enemy.equippedWeapon);
		}

		return physicalPower + weaponBonus * 1;
	}

	public function getMagicalPower(): Int {
		// Magical Attack = magic + (Magic Might + Trinity of Magic Bonus) X Magic Effectiveness + Support Bonus
		return 0;
	}

	public function getDefensePower(): Int {
		// DP = Terrain Bonus + Defense + Support Bonus
		return defenseBonus + cs.def + 0;
	}

	public function getResistancePower(): Int {
		return 0;
	}

	public function getAttackSpeed(): Int {
		// If WWT ≤ Strength, then AS = Speed
		// If WWT > Strength, then AS = Speed - (Weapon Weight - Strength)
		if (equippedWeapon != null && equippedWeapon.weight > cs.str)
			return cs.spd + cs.str - equippedWeapon.weight;

		return cs.spd;
	}

	public function getHitRate(): Int {
		// Hit Rate = Weapon Accuracy + Skill x 2 + Luck / 2 + Support Bonus + S-Rank Bonus
		var hitRate: Int = 100;

		if (equippedWeapon != null)
			hitRate = equippedWeapon.hitRate;

		return Std.int(hitRate + cs.skl * 2 + cs.lck / 2 + 0 + 0);
	}

	public function getEvasionRate(): Int {
		// Evade = Attack Speed x 2 + Luck + Terrain Bonus + Support Bonus
		return getAttackSpeed() * 2 + cs.lck + avoidBonus + 0;
	}

	public function repeatsAttack(enemy: Unit): Bool {
		var doubleAttackThreshold = 4;

		return (getAttackSpeed() - enemy.getAttackSpeed()) > doubleAttackThreshold;
	}

	public function getAccuracy(enemy: Unit): Int {
		// Accuracy = Hit Rate (Attacker) - Evade (Defender) + Triangle Bonus
		return Utils.min(100, Utils.max(0, getHitRate() - enemy.getEvasionRate() +
			Weapon.getAccuracyBonus(equippedWeapon, enemy.equippedWeapon)));
	}

	public function calcPhysicalDamage(enemy: Unit): Int {
		return Utils.max(getPhysicalPower(enemy) - enemy.getDefensePower(), 0);
	}

	public function calcMagicalDamage(enemy: Unit): Int {
		return Utils.max(getMagicalPower() - enemy.getResistancePower(), 0);
	}

	public function attack(enemy: Unit, callback: Void -> Void) {
		performAttack(enemy, 2, function() {
			if (enemy.isAlive() && enemy.canCounterattack(this)) {
				// Defender counter attacks
				enemy.performAttack(this, 1 ,function() {
					if (enemy.repeatsAttack(this) && isAlive()) {
						// Defender attacks again
						enemy.performAttack(this, 1, function() {
							if (isAlive() && repeatsAttack(enemy)) {
								// Attacker's second attack
								performAttack(enemy, 2, function() {
									callback();
								});
							} else {
								callback();
							}
						});
					} else if (isAlive() && repeatsAttack(enemy) && enemy.isAlive()) {
						// Attacker's second attack
						performAttack(enemy, 2, function() {
							callback();
						});
					} else {
						callback();
					}
				});
			} else if (isAlive() && repeatsAttack(enemy) && enemy.isAlive()) {
				// Attacker's second attack
				performAttack(enemy, 2, function() {
					callback();
				});
			} else {
				callback();
			}
		});
	}

	private function performAttack(enemy: Unit, which: Int, callback: Void -> Void) {
		var xDir: Int = Utils.sign0(enemy.pos.x - pos.x);
		var yDir: Int = Utils.sign0(enemy.pos.y - pos.y);

		FlxTween.tween(sprite, { x: sprite.x + xDir * 4, y: sprite.y + yDir * 4 }, 0.1, { onComplete: function(tween: FlxTween) {
			FlxTween.tween(sprite, { x: sprite.x + xDir * -4, y: sprite.y + yDir * -4 }, 0.1);
		} });

		if (getAccuracy(enemy) >= Std.random(100)) {
			enemy.setHP(Utils.max(0, enemy.cs.hp - calcPhysicalDamage(enemy)));

			FlxSpriteUtil.flicker(enemy.sprite, 0.2, 0.05, true, function(flicker: FlxFlicker) {
			});
		} else {
			// Attack misses
		}
	}

	public function canCounterattack(enemy: Unit): Bool {
		if (enemy != null) {
			var distance = MapUtils.calcDistance(pos, enemy.pos);
			return atkRangeMin >= distance && atkRangeMax <= distance;
		}

		return false;
	}*/

	public function isAlive(): Bool {
		return cs.hp > 0;
	}

	public function die(callback: Void -> Void) {
		function setAlpha(sprite: FlxSprite, value: Float) { sprite.alpha = value; };
		FlxTween.num(1, 0, 0.2, { onComplete: function(_) { callback(); } }, setAlpha.bind(sprite));
	}

	public function setHP(hp: Int) {
		cs.hp = hp;
	}

	public function resetStats() {
		cs.hp = os.hp;
		cs.str = os.str;
		cs.mgc = os.mgc;
		cs.skl = os.skl;
		cs.spd = os.spd;
		cs.lck = os.lck;
		cs.def = os.def;
		cs.res = os.res;
		cs.mov = os.mov;
	}

	public static function changeAnimColour(frames: Array<Int>, player: Int): Array<Int> {
		var newFrames: Array<Int> = new Array<Int>();

		for (i in 0 ... frames.length)
			newFrames.push(frames[i] + spritesheetOffset * player);

		return newFrames;
	}

	public function canCapture(): Bool {
		return unitType.uName == 'infantry' || unitType.uName == 'mech';
	}

	public function canAttack(unitsInRange: Array<Unit>): Array<Unit> {
		var targets: Array<Unit> = new Array<Unit>();

		for (unit in unitsInRange) {
			var distance: Int = TilePoint.distance(unit.pos, pos);

			var index: Int = 0;
			var found: Bool = false;
			while (!found && index < unitType.weapons.length) {
				found = unitType.weapons[index].targets.indexOf(unit.unitType.type) >= 0;
				index++;
			}

			if (found) targets.push(unit);
		}

		return targets;
	}

	public function isTransport(): Bool {
		return Type.getClassName(Type.getSuperClass(Type.getClass(this))) == "entities.Transport";
	}

	public function setActionIconVisible(visible: Bool) {
		actionIcon.visible = visible;
	}
}

class UnitFactory {
	public static function create(posX: Int, posY: Int, unitType: UnitType, player: Int): Unit {
		var unit: Unit = null;

		switch unitType.uName {
			case "infantry":	unit = new Infantry(posX, posY, unitType, player);
			case "mech":		unit = new Infantry(posX, posY, unitType, player);
			case "apc": 		unit = new TransportAPC(posX, posY, player);
			default: 			unit = new Unit(posX, posY, unitType, player);
		}

		return unit;
	}
}

class UnitStats {
	public var hp: Int;
	public var str: Int;
	public var mgc: Int;
	public var skl: Int;
	public var spd: Int;
	public var lck: Int;
	public var def: Int;
	public var res: Int;
	public var mov: Int;

	public function new() {}
}

enum UnitStatus {
	STATUS_AVAILABLE;
	STATUS_SELECTED;
	STATUS_MOVING;
	STATUS_MOVED;
	STATUS_LOADING;
	STATUS_LOADED;
	STATUS_UNLOADING;
	STATUS_ATTACK_READY;
	STATUS_ATTACKING;
	STATUS_ON_INVENTORY;
	STATUS_ON_SELECT_WEAPON;
	STATUS_DONE;
}

enum UnitMovementType {
	ONFOOT;
	RIDE;
	FLY;
}
