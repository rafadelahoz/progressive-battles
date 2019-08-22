package entities;

import flixel.FlxSprite;

import utils.MapUtils;
import utils.data.UnitType;
import utils.data.Set;
import utils.data.TilePoint;
import utils.Data;

class Transport extends Unit {

	public var capacity: Int;
	public var unitsOnBoard: Array<Unit>;
	public var unitsAllowed: Set<String>;
	public var terrainsAllowed: Set<String>;

	public function new(posX: Int, posY: Int, unitType: UnitType, player: Int) {
		super(posX, posY, unitType, player);

		actionIcon = new FlxSprite(sprite.x + Unit.marginLeftActionIcon, sprite.y + Unit.marginTopActionIcon);
		actionIcon.loadGraphic("assets/images/ui/icon-load-8.png", false, 8, 8);
		actionIcon.visible = false;
		add(actionIcon);

		unitsOnBoard = new Array<Unit>();
		unitsAllowed = new Set<String>(stringCompare);
		terrainsAllowed = new Set<String>(stringCompare);
	}

	public function canLoad(unit: Unit): Bool {
		return unitsOnBoard.length < capacity && unitsAllowed.contains(unit.unitType.uName);
	}

	public function load(unit: Unit) {
		if (canLoad(unit)) {
			unit.visible = false;
			actionIcon.visible = true;
			unitsOnBoard.push(unit);
			battle.getCurrentPlayer().army.remove(unit);
		}
	}

	public function canUnload(unit: Unit, tileIndex: Int): Bool {
		var terrain: String = MapUtils.getTerrainType(battle, tileIndex).uName;
		return Data.getInstance().terrains.get(terrain).movCost.get(unit.unitType.uName) < 99;
	}

	public function unload(unitIndex: Int, posX: Int, posY: Int) {
		var tileIndex: Int = MapUtils.coordsToIndex(posX, posY);
		if (unitIndex >= 0 && unitIndex < unitsOnBoard.length && canUnload(unitsOnBoard[unitIndex], tileIndex)) {
			var unit: Unit = unitsOnBoard[unitIndex];
			unitsOnBoard.splice(unitIndex, 1);

			if (unitsOnBoard.length == 0)
				actionIcon.visible = false;

			unit.placeUnit(posX, posY);
			unit.disable();
			unit.visible = true;

			battle.getCurrentPlayer().army.push(unit);
			battle.scene.update(battle);
		}
	}

	public function getUnloadableUnits(): Set<Int> {
		var units: Set<Int> = new Set<Int>(function(a: Int, b: Int) { return a == b; });

		for (tile in MapUtils.getAdjacentTiles(battle, pos.x, pos.y)) {
			for (i in 0 ... unitsOnBoard.length) {
				if (canUnload(unitsOnBoard[i], tile))
					units.add(i);
			}
		}

		return units;
	}

	public function getTilesToUnload(unitIndex: Int): Array<TilePoint> {
		var tiles: Array<TilePoint> = new Array<TilePoint>();
		var unit: Unit = unitsOnBoard[unitIndex];

		for (tile in MapUtils.getAdjacentTiles(battle, pos.x, pos.y)) {
			var terrain: String = MapUtils.getTerrainType(battle, tile).uName;
			if (canUnload(unit, tile))
				tiles.push(MapUtils.indexToPoint(tile));
		}

		return tiles;
	}

	override public function onWait() {
		actionIcon.visible = unitsOnBoard.length > 0;
		super.onWait();
	}

	public static function stringCompare(a: String, b: String): Bool {
		return a == b;
	}
}
