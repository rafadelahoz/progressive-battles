package ui;

class UnitInfoDialog extends BattleDialog {

	public function new() {
		var width = 104;
		var height = 152;
		var margin = 4;
		path = "assets/images/ui/dialog-unit-info";

		super(width, height, margin, margin, BattleDialog.QUADRANT_TOP_RIGHT);
		updateBackground();

		visible = false;
	}
}
