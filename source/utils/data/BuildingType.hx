package utils.data;

class BuildingType {
	public var id: Int;
	public var name: String;
	public var uName: String;
	public var def: Int;
	public var res: Int;
	public var funds: Int;
	public var gfxPath: String;
	public var spriteColumn: Int;
	public var units: Array<UnitCost>;

	public function new(data: Dynamic) {
		uName = Reflect.field(data, "uName");
		name = Reflect.field(data, "name");
		def = Reflect.field(data, "def");
		res = Reflect.field(data, "res");
		funds = Reflect.field(data, "funds");
		gfxPath = Reflect.field(data, "gfx-path");
		spriteColumn = Reflect.field(data, "spriteColumn");

		units = new Array<UnitCost>();
		var unitCosts: Array<Dynamic> = Reflect.field(data, "units");
		for (unitCost in unitCosts) {
			var unit = new UnitCost(unitCost);
			units.push(unit);
		}
	}
}

class UnitCost {
	public var unit: String;
	public var cost: Int;

	public function new(data: Dynamic) {
		unit = Reflect.field(data, "unit");
		cost = Reflect.field(data, "cost");
	}
}
