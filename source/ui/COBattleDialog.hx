package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import states.BattleState;

class COBattleDialog extends BattleDialog {

	private static var marginLeftFunds: Int = 12;
	private static var marginTopFunds: Int = -1;
	private static var marginLeftTurn: Int = 2;
	private static var marginTopTurn: Int = 10;

	private var fundsText: FlxText;
	private var turnText: FlxText;

	public function new() {
		var width = 64;
		var height = 30;
		var margin = 4;
		path = "assets/images/ui/co-indicator";

		super(width, height, margin, margin, BattleDialog.QUADRANT_TOP_LEFT);
		updateBackground();

		fundsText = new FlxText(bgX + marginLeftFunds, bgY + marginTopFunds, 48, "0");
		fundsText.alignment = FlxTextAlign.RIGHT;
		fundsText.setFormat("assets/fonts/font-pixel-8.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fundsText);

		turnText = new FlxText(bgX + marginLeftTurn, bgY + marginTopTurn, "Day 1");
		turnText.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxColor.BLACK, FlxTextBorderStyle.NONE);
		add(turnText);
	}

	public function refresh() {
		var newCurrentPlayer: Int = _map.getCurrentPlayer().id;
		if (currentPlayer != newCurrentPlayer) {
			currentPlayer = newCurrentPlayer;
		}

		updateBackground();

		fundsText.text = Std.string(_map.getCurrentPlayer().funds);
		turnText.text = "Day " + Std.string(_map.turn);
	}

	override public function update(elapsed: Float) {
		if (_map.cursor.visible && covers(_map.cursor.pos.x, _map.cursor.pos.y))
			moveToQuadrant(BattleDialog.QUADRANT_TOP_RIGHT);
		else
			restorePosition();

		super.update(elapsed);
	}
}
