package entities;

import flixel.FlxG;
import flixel.util.FlxColor;

import utils.Data;
import utils.data.UnitType;
import utils.data.BuildingType;
import utils.MapUtils;

import states.BattleState;

import entities.Unit;

class BuildingBase extends Building {

	public static var baseUnits: Array<UnitType> = null;

	private var data: Data;

	public function new(x: Int, y: Int) {
		super(x, y);

		data = Data.getInstance();
		buildingType = data.buildings.get("base");

		sprite.loadGraphic(buildingType.gfxPath, true, 16, 32);
		sprite.animation.frameIndex = buildingType.spriteColumn;
	}

	override public function onSelect() {
		super.onSelect();

		if (canSelect()) {
			_map.status = BattleState.STATUS_UNIT_DEPLOYMENT;
			_map.cursor.hide();
			_map.unitDeploymentDialog.setBuilding(this);
			_map.unitDeploymentDialog.show();
			_map.unitInfoDialog.show();
		}
	}

	override public function onCancel() {
		super.onCancel();

		_map.unitDeploymentDialog.hide();
		_map.unitInfoDialog.hide();
		_map.cursor.show();
		_map.status = BattleState.STATUS_MAP_NAVIGATION;
	}

	override public function deployUnit(unitName: String) {
		var unitCost = getUnitCost(unitName, buildingType);

		if (_map.status == BattleState.STATUS_UNIT_DEPLOYMENT && unitCost <= _map.getCurrentPlayer().funds) {
			_map.getCurrentPlayer().funds -= unitCost;

			var newUnit: Unit = UnitFactory.create(posX, posY, data.units.get(unitName), _map.getCurrentPlayer().id);
			newUnit.disable();
			_map.getCurrentPlayer().army.push(newUnit);
			_map.scene.getLayer("units").add(newUnit);
			_map.scene.update(_map);

			_map.coDialog.refresh();
			_map.syncIdleAnimations();

			onCancel();
		}
	}
}
