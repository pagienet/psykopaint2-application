package net.psykosoft.psykopaint2.utils.decorators
{
	import starling.core.Starling;
	import starling.display.DisplayObject;
	
	public class MoveButtonDecorator extends AbstractButtonDecorator
	{
		private var _originalObjectProperties:Object;
		
		/* DO X/Y  SCALE OR ALPHA OPERATIONS */
		public function MoveButtonDecorator(decorated:DisplayObject, speed:Number, paramObject:Object)
		{
			super(decorated, speed, paramObject);
			
		}
		
		
		
		override protected function onBeginTouch():void{
			
			if(!_originalObjectProperties){
				_originalObjectProperties = {};
				_originalObjectProperties.x = decorated.x;
				_originalObjectProperties.y = decorated.y;
				_originalObjectProperties.scaleX = decorated.scaleX;
				_originalObjectProperties.scaleY = decorated.scaleY;
				_originalObjectProperties.alpha = decorated.alpha;
			}
			
			//CENTER THE SCALING
			_paramObject.onUpdate = function ():void
			{
				_decorated.x = _originalObjectProperties.x + (1.0 - _decorated.scaleX) / 2.0 * _decorated.width;
				_decorated.y = _originalObjectProperties.y + (1.0 - _decorated.scaleY) / 2.0 * _decorated.height;
			}
			Starling.juggler.removeTweens(_decorated);
			Starling.juggler.tween(_decorated, _speed, _paramObject);
		}	
		
		override protected function onEndTouch():void {
			
			
			var shiftX:Number = _decorated.x - _originalObjectProperties.x - (1.0 - _decorated.scaleX) / 2.0 * _decorated.width;
			var shiftY:Number = _decorated.y - _originalObjectProperties.y - (1.0 - _decorated.scaleY) / 2.0 * _decorated.height;
			
			//CENTER THE SCALING
			_originalObjectProperties.onUpdate = function ():void{
				
				_decorated.x =shiftX+ _originalObjectProperties.x + (1.0 - _decorated.scaleX) / 2.0 * _decorated.width;
				_decorated.y =shiftY+ _originalObjectProperties.y + (1.0 - _decorated.scaleY) / 2.0 * _decorated.height;
			}
			//DISPOSE WHEN TRANSITION COMPLETE
			_originalObjectProperties.onComplete = function ():void{
				
				_originalObjectProperties = null
			}
			Starling.juggler.tween(_decorated, _speed, _originalObjectProperties);
			
			
			
		}		
	}
}