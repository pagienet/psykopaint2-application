package net.psykosoft.psykopaint2.base.utils.events
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	public class EventStopper
	{
		
		public static function stop(target:DisplayObject):void{
			
			
			target.addEventListener(MouseEvent.MOUSE_OVER, onSomething);
			target.addEventListener(MouseEvent.MOUSE_OUT, onSomething);
			target.addEventListener(MouseEvent.ROLL_OVER, onSomething);
			target.addEventListener(MouseEvent.ROLL_OUT, onSomething);
			target.addEventListener(MouseEvent.MOUSE_DOWN, onSomething);
			target.addEventListener(MouseEvent.MOUSE_UP, onSomething);
			target.addEventListener(MouseEvent.CLICK, onSomething);
			target.addEventListener(MouseEvent.MOUSE_WHEEL, onSomething);
			
		}
		
		
		public static function removeStop(target:DisplayObject):void{
			
			
			target.removeEventListener(MouseEvent.MOUSE_OVER, onSomething);
			target.removeEventListener(MouseEvent.MOUSE_OUT, onSomething);
			target.removeEventListener(MouseEvent.ROLL_OVER, onSomething);
			target.removeEventListener(MouseEvent.ROLL_OUT, onSomething);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, onSomething);
			target.removeEventListener(MouseEvent.MOUSE_UP, onSomething);
			target.removeEventListener(MouseEvent.CLICK, onSomething);
			target.removeEventListener(MouseEvent.MOUSE_WHEEL, onSomething);
		}
		
		private static function onSomething(event : MouseEvent) : void
		{
			event.stopImmediatePropagation();
		}
	}
}