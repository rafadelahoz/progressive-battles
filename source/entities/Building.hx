package entities;

import flixel.FlxG;

import utils.MapUtils;

import states.BattleState;

import utils.data.BuildingType;

class Building extends Entity {

	public static var buildingTypes = 6;

	public var belongsTo: Int;
	public var capturedBy: Int;
	public var res: Int;

	public var posX: Int;
	public var posY: Int;

	public var _map: BattleState;
	public var buildingType: BuildingType;

	private var marginTop: Int;

	public function new(x: Int, y: Int) {
		super(x, y);

		belongsTo = null;
		capturedBy = null;
		res = 20;
		marginTop = -16;

		if (_map == null)
			_map = cast(FlxG.state, BattleState);
	}

	public function canSelect(): Bool {
		return !MapUtils.isTileOccupied(_map, MapUtils.coordsToIndex(posX, posY));
	}

	public function onSelect() {}

	public function onCancel() {}

	public function setBelongsTo(belongsTo: Int) {
		this.belongsTo = belongsTo;
		sprite.animation.frameIndex = getFrameIndex();
	}

	public function getFrameIndex(): Int {
		return (this.belongsTo != null ? this.belongsTo + 1 : 0) * buildingTypes + buildingType.spriteColumn;
	}

	public function place(posX: Int, posY: Int) {
		this.posX = posX;
		this.posY = posY;

		sprite.x = posX * ViewPort.tileSize;
		sprite.y = posY * ViewPort.tileSize + marginTop;
	}

	public function deployUnit(unitName: String) {}

	public function getUnitCost(unitName: String, buildingType: BuildingType): Int {
		var found: Bool = false;
		var index: Int = 0;
		var cost: Int = -1;

		while (!found && index < buildingType.units.length) {
			found = unitName == buildingType.units[index].unit;
			index++;
		}

		if (found) cost = buildingType.units[index - 1].cost;

		return cost;
	}

	public function canDeployUnit(unitName: String, buildingType: BuildingType): Bool {
		var unitCost: Int = getUnitCost(unitName, buildingType);
		var tileIndex: Int = MapUtils.coordsToIndex(posX, posY);

		return _map.status == BattleState.STATUS_UNIT_DEPLOYMENT && unitCost > -1 &&
			unitCost <= _map.getCurrentPlayer().funds && !MapUtils.isTileOccupied(_map, tileIndex);
	}

	public function getBuildingType(): String {
		return buildingType.uName;
	}
}
