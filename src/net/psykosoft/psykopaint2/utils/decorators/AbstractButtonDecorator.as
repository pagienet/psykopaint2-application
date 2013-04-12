package net.psykosoft.psykopaint2.utils.decorators
{
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class AbstractButtonDecorator
	{
		protected var _decorated : DisplayObject;
		protected var _speed:Number;

		/* CONTAINS THE ANY VALUES THAT THE TRANSITION MIGHT NEED */
		protected  var _paramObject:Object;
		
		/* WARNING: AUTOMATICALLY REMOVE ITSELF WHEN REMOVED FROM STAGE */

		public function AbstractButtonDecorator(decorated:DisplayObject,speed:Number=0, paramObject:Object=null)
		{
			_speed = speed;
			_paramObject = paramObject;
			
			_decorated = decorated;
			_decorated.addEventListener(TouchEvent.TOUCH, onTouch);
			_decorated.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		
		
		
		private function onRemoveFromStage():void
		{
			destroy();
		}
		
		private function onTouch(e:TouchEvent):void
		{
			
			var touch:Touch= e.touches[0];
			if(touch.phase==TouchPhase.BEGAN){
				
				onBeginTouch();
			}else if(touch.phase==TouchPhase.ENDED){
				
				onEndTouch();
			}else if(touch.phase==TouchPhase.MOVED){
				
				onMoveTouch();
			}
		}		
		
		/* OVERRIDE ME */
		protected function onBeginTouch():void
		{
			
			
		}
		
		
		/* OVERRIDE ME */
		protected function onEndTouch():void
		{
			
			
		}
		
		/* OVERRIDE ME */
		protected function onMoveTouch():void
		{
			
			
		}
		
		public function destroy() : void
		{
			trace("[AbstractButtonDecorator]destroy");
			_decorated.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			_decorated.removeEventListener(TouchEvent.TOUCH, onTouch);
			_decorated = null;
			_paramObject = null;
		}
		
		
		public function get speed():Number
		{
			return _speed;
		}
		
		public function set speed(value:Number):void
		{
			_speed = value;
		}

		
		public function get decorated() : DisplayObject
		{
			return _decorated;
		}
		
	}
}