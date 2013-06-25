package net.psykosoft.psykopaint2.base.ui.components
{


	public class HItemScroller extends HSnapScroller
	{
		public function HItemScroller() {
			super();
		}

		override protected function evaluateNewSnapPointFromPosition( px:Number ):void {
			_positionManager.pushSnapPoint( px );
		}
	}
}
