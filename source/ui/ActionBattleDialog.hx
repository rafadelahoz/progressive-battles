package ui;

import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxColor;

import ui.BattleDialog;

class ActionBattleDialog extends BattleDialog {

	private static inline var lineHeight: Int = 14;
	private static inline var marginTop: Int = 6;
	private static inline var marginTopText: Int = -3;
	private static inline var marginLeft: Int = 24;
	private static inline var marginLeftArrow: Int = -10;
	private static inline var marginTopArrow: Int = -2;
	private static inline var marginLeftIcon: Int = 8;
	private static inline var marginTopIcon: Int = 0;

	private var selected: Int;
	private var menuItems: Array<MenuEntry>;
	private var enabledEntries: Array<Int>;		// Each position points to the index in menuItems, keep this sorted
	private var disabledEntries: Array<Int>;	// Each position points to the index in menuItems, keep this sorted
	private var arrow: FlxSprite;

	private var width: Int;
	private var height: Int;
	private var rows: Int;

	private var currentPath: String;

	public function new(quadrant: Int) {
		rows = 5;
		width = 64;
		height = marginTop * 2 + lineHeight * rows;
		path = "assets/images/ui/context-menu-";

		super(width, height, 8, 4, quadrant);

		menuItems = new Array<MenuEntry>();
		enabledEntries = new Array<Int>();
		disabledEntries = new Array<Int>();

		background = new FlxSprite(bgX, bgY);
		add(background);

		addNewEntry("attack", "Fire", "assets/images/ui/icon-fire-14.png");
		addNewEntry("no-attack", "Fire", "assets/images/ui/icon-notfire-14.png");
		addNewEntry("load", "Load", "assets/images/ui/icon-load-14.png");
		addNewEntry("unload", "Drop", "assets/images/ui/icon-load-14.png");
		addNewEntry("capture", "Capture", "assets/images/ui/icon-capture-14.png");
		addNewEntry("wait", "Wait", "assets/images/ui/icon-wait-14.png");

		arrow = new FlxSprite(x, y);
		arrow.loadGraphic("assets/images/ui/arrow.png", true, 18, 18);
		arrow.animation.add("default", [0, 1], 3, true);
		arrow.animation.play("default");
		add(arrow);

		highlight(0);
		visible = false;
	}

	override public function update(elapsed: Float) {
		if (covers(_map.cursor.pos.x, _map.cursor.pos.y)) {
			moveToQuadrant(BattleDialog.QUADRANT_TOP_LEFT);
		} else {
			restorePosition();
		}

		super.update(elapsed);
	}

	private function highlight(pos: Int) {
		if (pos >= 0 && pos < enabledEntries.length) {
			enabledEntries.sort(function(a: Int, b: Int) {
				return a - b;
			});

			disabledEntries.sort(function(a: Int, b: Int) {
				return a - b;
			});

			placeEnabledEntries();

			arrow.x = vpX + x + marginLeftArrow;
			arrow.y = vpY + y + marginTop + pos * lineHeight + marginTopArrow;
			selected = pos;
		}
	}

	public function nextItem() {
		var newPos = (selected + 1) % enabledEntries.length;
		highlight(newPos);
	}

	public function prevItem() {
		var newPos = selected - 1;
		if (newPos == -1)
			newPos = enabledEntries.length - 1;

		highlight(newPos);
	}

	public function select(): String {
		return menuItems[enabledEntries[selected]].value;
	}

	override public function show() {
		updateBackground();

		highlight(0);
		selected = 0;
		super.show();
	}

	public function addNewEntry(value: String, label: String, iconPath: String) {
		var entry: MenuEntry = new MenuEntry();
		entry.value = value;
		entry.label = label;
		entry.gfxPath = iconPath;
		entry.icon = new FlxSprite(x + marginLeftIcon, y + marginTop + marginTopIcon + menuItems.length * lineHeight);
		entry.icon.loadGraphic(iconPath, false, 14, 14);
		entry.text = new FlxText(x + marginLeft, y + marginTop + marginTopText + menuItems.length * lineHeight, label);
		entry.text.setFormat("assets/fonts/font-pixel-7.ttf", 16, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		enabledEntries.push(menuItems.length);
		menuItems.push(entry);

		add(entry.text);
		add(entry.icon);
	}

	public function enableEntry(entryName: String) {
		var index: Int = 0;
		var found: Bool = false;

		while (!found && index < disabledEntries.length) {
			var entry: MenuEntry = menuItems[disabledEntries[index]];
			found = entry.value == entryName && !entry.enabled;
			if (found) {
				entry.text.visible = true;
				entry.icon.visible = true;
				entry.enabled = true;

				enabledEntries.push(disabledEntries[index]);
				disabledEntries.splice(index, 1);
				rows = enabledEntries.length;

				updateBackground();
			}

			index++;
		}

		highlight(0);
	}

	public function disableEntry(entryName: String) {
		var index: Int = 0;
		var found: Bool = false;

		while (!found && index < enabledEntries.length) {
			var entry: MenuEntry = menuItems[enabledEntries[index]];
			found = entry.value == entryName && entry.enabled;
			if (found) {
				entry.text.visible = false;
				entry.icon.visible = false;
				entry.enabled = false;

				disabledEntries.push(enabledEntries[index]);
				enabledEntries.splice(index, 1);
				rows = enabledEntries.length;

				updateBackground();
			}

			index++;
		}

		highlight(0);
	}

	public function placeEnabledEntries() {
		var index: Int = 0;
		for (i in enabledEntries) {
			menuItems[i].text.y = bgY + marginTop + marginTopText + index * lineHeight;
			menuItems[i].icon.y = bgY + marginTop + marginTopIcon + index * lineHeight;
			index++;
		}
	}

	override public function updateBackground() {
		if (background == null) {
			background = new FlxSprite(bgX, bgY);
			add(background);
		}

		if (rows > 0) {
			var fullPath: String = path + Std.string(rows) + "_P" + Std.string(currentPlayer) + ".png";
			if (fullPath != currentPath) {
				background.loadGraphic(fullPath, width, marginTop * 2 + lineHeight * rows);
				currentPath = fullPath;
			}
		}
	}
}
