package net.psykosoft.psykopaint2.paint.views.color
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class UndoBtn extends MovieClip
	{
		public function UndoBtn()
		{
			super();
			stop();
			this.buttonMode=true;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		
		private function onMouseDown(e:MouseEvent):void{
			if(this.currentFrame==1){
				this.gotoAndStop(2);
			}else {
				this.gotoAndStop(1);

			}
		}
	}
}