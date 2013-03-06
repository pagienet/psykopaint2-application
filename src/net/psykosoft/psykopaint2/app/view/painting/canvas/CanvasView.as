package net.psykosoft.psykopaint2.app.view.painting.canvas
{

	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;

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
