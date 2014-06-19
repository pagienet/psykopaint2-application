package net.psykosoft.psykopaint2.paint.views.color
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class ClearBtn extends MovieClip
	{
		public function ClearBtn()
		{
			super();
			stop();
			this.buttonMode=true;
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);

		}
		
		protected function onRemoved(event:Event):void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			

			this.removeEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
		}
		
		private function onMouseDown(e:MouseEvent):void{
			
				this.gotoAndStop(2);
				this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			this.gotoAndStop(1);
			this.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			
		}
		
		public function reset():void
		{
			this.gotoAndStop(1);
		}
	}
}