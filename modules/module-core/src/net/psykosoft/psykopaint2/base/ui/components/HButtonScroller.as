package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.DisplayObject;

import net.psykosoft.psykopaint2.core.views.components.button.SbButton;


public class HButtonScroller extends HSnapScroller
	{

		private var _itemPositionOffsetX:Number;

		private const ITEM_GAP_X:Number = 8;

		public function HButtonScroller() {
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

		override public function invalidateContent():void {
			// Add snap points.
			var i:uint, j:uint;
			var len:uint = _container.numChildren;
			for( i = 0; i < len; i++ ) {
				var child:DisplayObject = _container.getChildAt( i ) as DisplayObject;
				if ( child is ButtonGroup ) {
					var childAsButtonGroup:ButtonGroup = child as ButtonGroup;
					var groupLen:uint = childAsButtonGroup.numButtons;
					for( j = 0; j < groupLen; j++ ) {
						var aButton:SbButton = childAsButtonGroup.buttons[ j ];
						evaluateDimensionsFromChild( aButton, childAsButtonGroup.x );
						evaluateNewSnapPointFromPosition( childAsButtonGroup.x + aButton.x );
					}
				}
				else {
					evaluateDimensionsFromChild( child );
					evaluateNewSnapPointFromPosition( child.x );
				}
			}
			// Contain edges.
			containEdgeSnapPoints();
			// Dock at first snap point.
			if( _positionManager.numSnapPoints > 0 ) {
				_positionManager.snapAtIndexWithoutEasing( 0 );
			}
		}

		public function addItem( item:DisplayObject, centerObject:Boolean = true ):DisplayObject {
			item.x = _itemPositionOffsetX;
			item.y = 10;
			if( centerObject ) {
				item.x += item.width / 2;
				item.y += item.height / 2;
			}
			_itemPositionOffsetX += item.width + ITEM_GAP_X;
			return super.addChild( item );
		}
	}
}
