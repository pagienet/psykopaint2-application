package net.psykosoft.psykopaint2.base.ui.components
{


	public class HPageScroller extends HSnapScroller
	{
		public function HPageScroller() {
			super();
		}

		override protected function evaluateNewSnapPointFromPosition( px:Number ):void {
			var ratio:Number = Math.floor( px / _visibleWidth );
            if( ratio >= _positionManager.numSnapPoints ){
				var snap:Number = ratio * _visibleWidth + _visibleWidth / 2;
			    _positionManager.pushSnapPoint( snap );
            }
		}
	}
}
