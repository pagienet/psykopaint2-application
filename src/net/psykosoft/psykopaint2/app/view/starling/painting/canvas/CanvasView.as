package net.psykosoft.psykopaint2.app.view.starling.painting.canvas
{

	import net.psykosoft.psykopaint2.app.view.starling.base.StarlingViewBase;

	import starling.display.Sprite;

	public class CanvasView extends StarlingViewBase
	{
		public function CanvasView() {
			super();
		}

		public function set renderedCanvasContainer( sprite:Sprite ):void {
			addChild( sprite );
		}
	}
}
