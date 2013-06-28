package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Shape;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class CanvasView extends ViewBase
	{
		
		private var _transformViewActive:Boolean;
		private var _transformFrame:Shape;
		
		public function CanvasView() {
			super();
			_transformViewActive = false;
		}
		
		public function showTranformView( enable:Boolean):void
		{
			if ( _transformViewActive == enable ) return;
			
			_transformViewActive = enable;
			if ( _transformViewActive )
			{
				if ( !_transformFrame )
				{
					_transformFrame = new Shape();
					_transformFrame.graphics.lineStyle(0,0);
					_transformFrame.graphics.drawRect(2,2,stage.stageWidth-4,stage.stageHeight-4);
				}
				addChild(_transformFrame);
			} else {
				removeChild(_transformFrame);
			}
		}
	}
}
