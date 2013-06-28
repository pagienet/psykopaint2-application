package net.psykosoft.psykopaint2.base.ui.components {
import flash.display.DisplayObject;


public class HItemScroller extends HSnapScroller {

	private var _itemPositionOffsetX:Number = 0; //TODO

	private const ITEM_GAP_X:Number = 8;

	public function HItemScroller() {
		super();
	}

	override protected function evaluateNewSnapPointFromPosition(px:Number):void {
		_positionManager.pushSnapPoint(px);
	}

	override public function reset():void {
		_itemPositionOffsetX = 0; //TODO
		// TODO
		super.reset();
	}

	override public function addChild(value:DisplayObject):DisplayObject {
		value.x = _itemPositionOffsetX;
		_itemPositionOffsetX += value.width + ITEM_GAP_X;
		trace( this, ">>> " + _itemPositionOffsetX );
		return super.addChild(value);
	}
}
}
