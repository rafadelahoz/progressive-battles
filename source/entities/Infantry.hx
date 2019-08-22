package entities;

import flixel.FlxSprite;

import entities.Building;

import utils.Utils;
import utils.data.UnitType;

class Infantry extends Unit {

	public var isCapturing: Bool;
	public var capturing: Building;

	public function new(posX: Int, posY: Int, unitType: UnitType, player: Int) {
		super(posX, posY, unitType, player);

		actionIcon = new FlxSprite(sprite.x + Unit.marginLeftActionIcon, sprite.y + Unit.marginTopActionIcon);
		actionIcon.loadGraphic("assets/images/ui/icon-capture-8.png", false, 8, 8);
		actionIcon.visible = false;
		add(actionIcon);

		isCapturing = false;
		capturing = null;
	}

	public function capture(building: Building) {
		isCapturing = true;
		capturing = building;
		actionIcon.visible = true;
		building.res = Utils.max(0, building.res - hp);
		if (building.res == 0) {
			building.res = 20;
			building.setBelongsTo(player);
			actionIcon.visible = false;
			isCapturing = false;
			capturing = null;
			status = STATUS_DONE;
			// Handle HQ capture
		}
	}

	public function stopCapture() {
		if (isCapturing && capturing != null) {
			isCapturing = false;
			capturing.res = 20;
			capturing = null;
			actionIcon.visible = false;
		}
	}

	override public function setActionIconVisible(visible: Bool) {
		actionIcon.visible = visible && isCapturing;
	}
}
