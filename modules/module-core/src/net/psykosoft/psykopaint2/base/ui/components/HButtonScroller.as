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
			// Trace snap point - uncomment only for visual debugging.
//			_container.graphics.beginFill( 0x00FF00 );
//			_container.graphics.drawCircle( px, 0, 10 );
//			_container.graphics.endFill();
		}

		override public function reset():void {
			_itemPositionOffsetX = 0;
			super.reset();
		}

		override public function invalidateContent():void {

			// Contain edges - modifies near edge snap points so that the content never scrolls too far from the edges.
			containEdgeSnapPoints();

			// Dock at first snap point.
			dock();

			// Trace content width - uncomment only for visual debugging.
			/*_container.graphics.clear();
			_container.graphics.beginFill( 0x0000FF, 1.0 );
			_container.graphics.drawRect( 0, 0, contentWidth, 100 );
			_container.graphics.endFill();
			var i:uint;
			var len:uint = _positionManager.numSnapPoints;
			for( i = 0; i < len; ++i ) {
				var px:Number = _positionManager.getSnapPointAtIndex( i );
				_container.graphics.beginFill( 0x00FF00 );
				_container.graphics.drawCircle( px, 0, 10 );
				_container.graphics.endFill();
			}*/
		}

		public function addItem( item:DisplayObject, centerObject:Boolean = true ):DisplayObject {

			// Position item.
			item.x = _itemPositionOffsetX;
			item.y = 0;
			if( centerObject ) {
				item.x += item.width / 2;
				item.y += item.height / 2;
			}
			_itemPositionOffsetX += item.width + ITEM_GAP_X;

			// Evaluate content dimensions and snap points.
			if( item is ButtonGroup ) {
				var childAsButtonGroup:ButtonGroup = item as ButtonGroup;
				var i:uint;
				var groupLen:uint = childAsButtonGroup.numButtons;
				for( i = 0; i < groupLen; i++ ) {
					var aButton:SbButton = childAsButtonGroup.buttons[ i ];
					evaluateDimensionsFromChild( aButton, childAsButtonGroup.x );
					evaluateNewSnapPointFromPosition( childAsButtonGroup.x + aButton.x );
				}
			}
			else {
				evaluateDimensionsFromChild( item );
				evaluateNewSnapPointFromPosition( item.x );
			}

			return super.addChild( item );
		}
	}
}
