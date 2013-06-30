package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.DisplayObject;


	public class HItemScroller extends HSnapScroller
	{

		private var _itemPositionOffsetX:Number;

		private const ITEM_GAP_X:Number = 8;

		public function HItemScroller() {
			super();
			reset();
		}

		override protected function evaluateNewSnapPointFromPosition( px:Number ):void {
			_positionManager.pushSnapPoint( px );
		}

		override public function reset():void {
			_itemPositionOffsetX = 0;
			super.reset();
		}

		public function addItem( item:DisplayObject, centerObject:Boolean = true ):DisplayObject {
			item.x = _itemPositionOffsetX;
			item.y = 0;
			if( centerObject ) {
				item.x += item.width / 2;
				item.y += item.height / 2;
			}
			_itemPositionOffsetX += item.width + ITEM_GAP_X;
			return super.addChild( item );
		}
	}
}
