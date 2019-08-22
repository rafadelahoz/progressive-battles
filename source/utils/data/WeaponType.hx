package utils.data;

class WeaponType {
	public var name: String;
	public var targets: Array<String>;
	public var ammo: Int;
	public var power: Int;
	public var rangeMin: Int;
	public var rangeMax: Int;

	public function new(data: Dynamic) {
		name = Reflect.field(data, "name");
		targets = Reflect.field(data, "targets");
		ammo = Reflect.field(data, "ammo");
		power = Reflect.field(data, "power");
		rangeMin = Reflect.field(data, "rangeMin");
		rangeMax = Reflect.field(data, "rangeMax");
	}
}
