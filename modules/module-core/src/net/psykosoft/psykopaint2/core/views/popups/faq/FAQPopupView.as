package net.psykosoft.psykopaint2.core.views.popups.faq
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.psykosoft.psykopaint2.base.utils.events.EventStopper;
	
	public class FAQPopupView extends Sprite
	{
		public var closeBtn:MovieClip;
		public var bg:Sprite;

		
		public function FAQPopupView()
		{
			super();
			
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		
		private function onAddedToStage( event:Event ):void {
			
			closeBtn.stop();
			closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownCloseBtn);
			closeBtn.addEventListener(MouseEvent.MOUSE_UP,onMouseUpCloseBtn);
			
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			EventStopper.stop(bg);
			
		}
		
		protected function onMouseDownCloseBtn(event:MouseEvent):void
		{
			closeBtn.gotoAndStop(2);
			
		}
		
		protected function onMouseUpCloseBtn(event:MouseEvent):void
		{
			dispose();
		}
		
		public function dispose():void{
			
			//	dragArea.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownCloseBtn);
			closeBtn.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpCloseBtn);
			
			//EventStopper.removeStop(bg);
			
			this.parent.removeChild(this);
			
						
		}
		
	}
}