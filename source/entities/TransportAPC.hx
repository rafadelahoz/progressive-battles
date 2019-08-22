package entities;

import utils.Data;
import utils.MapUtils;
import utils.data.UnitType;

class TransportAPC extends Transport {

	public function new(posX: Int, posY: Int, player: Int) {
		var unitType: UnitType = Data.getInstance().units.get("apc");
		super(posX, posY, unitType, player);

		capacity = 1;

		unitsAllowed.add("infantry");
		unitsAllowed.add("mech");
	}
}
