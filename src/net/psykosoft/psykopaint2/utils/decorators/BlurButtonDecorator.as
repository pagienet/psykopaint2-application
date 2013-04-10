package net.psykosoft.psykopaint2.utils.decorators
{
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	
	public class BlurButtonDecorator extends AbstractButtonDecorator
	{
		
		
		public function BlurButtonDecorator(decorated:Sprite, speed:Number=0,paramObject:Object=null)
		{
			
			if(paramObject==null){
				paramObject = {blurX:4,blurY:4};
			}
			
			super(decorated, speed,paramObject);
		}
		
		override protected function onBeginTouch():void{
			var filter:BlurFilter = new BlurFilter();
			_decorated.filter = filter;
			Starling.juggler.tween(_decorated.filter, _speed, _paramObject);
		}	
		
		override protected function onEndTouch():void {
			
			//DISPOSE WHEN TRANSITION COMPLETE
			Starling.juggler.tween(_decorated.filter, _speed, {blurX:1,blurY:1,onComplete : function(){
				trace("dispose filter")
				_decorated.filter.dispose();
				_decorated.filter = null;
			}});
			
			
			
		}		
	}
}