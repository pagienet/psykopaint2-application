package net.psykosoft.psykopaint2.utils.decorators.buttons
{
	import starling.display.Sprite;
	import starling.filters.ColorMatrixFilter;

	public class InvertButtonDecorator extends AbstractButtonDecorator
	{
		
		
		public function InvertButtonDecorator(decorated : Sprite,speed:Number=0,paramObject:Object = null)
		{
			super(decorated,speed,paramObject);

		}
		
		
		override protected function onBeginTouch():void{
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
			colorMatrixFilter.invert()
			_decorated.filter = colorMatrixFilter;
			//Starling.juggler.tween(object.filter, _speed, { blurX: 2.0, blurY: 2.5 });
		}	
				
		override protected function onEndTouch():void {
				
			_decorated.filter.dispose();
			_decorated.filter = null;
			
		}		
		
		

	
	}
}