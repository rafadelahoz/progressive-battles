package entities;

import flixel.FlxG;
import flixel.util.FlxColor;

import utils.Data;
import utils.data.UnitType;
import utils.data.BuildingType;
import utils.MapUtils;

import states.BattleState;

import entities.Unit;

class BuildingCity extends Building {

	private var data: Data;

	public function new(x: Int, y: Int) {
		super(x, y);

		data = Data.getInstance();
		buildingType = data.buildings.get("city");

		sprite.loadGraphic(buildingType.gfxPath, true, 16, 32);
		sprite.animation.frameIndex = 0;
	}
}
