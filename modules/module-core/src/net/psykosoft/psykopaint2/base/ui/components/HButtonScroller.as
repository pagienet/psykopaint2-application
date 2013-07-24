package net.psykosoft.psykopaint2.base.ui.components
{
	import flash.display.DisplayObject;

	import net.psykosoft.psykopaint2.core.views.components.button.SbButton;

	/*
	* An HSnapScroller that expects SbButtons and ButtonGroups.
	* Positions each item next to each other.
	* Adds snap points at the position of each individual button.
	* */
	public class HButtonScroller extends HSnapScroller
	{
		private var _itemPositionOffsetX:Number;

		private const ITEM_GAP_X:Number = 8;

		public function HButtonScroller() {
			super();
		}

		override public function reset():void {
			_itemPositionOffsetX = 0;
			super.reset();
		}

		override public function invalidateContent():void {

			var i:uint = 0;
			var j:uint = 0;

			// Evaluate content dimensions and snap points from each child and sub-child.
			var numChildren:uint = _container.numChildren;
			for( i = 0; i < numChildren; i++ ) {
				var item:DisplayObject = _container.getChildAt( i );
				if( item is ButtonGroup ) {
					var childAsButtonGroup:ButtonGroup = item as ButtonGroup;
					var groupLen:uint = childAsButtonGroup.numButtons;
					for( j = 0; j < groupLen; j++ ) {
						var subButton:SbButton = childAsButtonGroup.buttons[ j ];
						evaluateDimensionsFromItemPositionAndWidth( subButton.x, subButton.width, childAsButtonGroup.x );
						evaluateNewSnapPointFromPosition( childAsButtonGroup.x + subButton.x );
					}
				}
				else {
					evaluateDimensionsFromItemPositionAndWidth( item.x, item.width );
					evaluateNewSnapPointFromPosition( item.x );
				}
			}

			containEdgeSnapPoints();
			dock();
		}

		public function addItem( item:DisplayObject, centerObject:Boolean = true ):void {

			// Position item.
			item.x = _itemPositionOffsetX;
			item.y = 0;
			if( centerObject ) {
				item.x += item.width / 2;
				item.y += item.height / 2;
			}
			_itemPositionOffsetX += item.width + ITEM_GAP_X;

			// Add to container.
			super.addChild( item );
		}
	}
}
