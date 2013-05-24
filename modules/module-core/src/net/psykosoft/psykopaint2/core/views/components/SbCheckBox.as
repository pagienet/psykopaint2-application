package net.psykosoft.psykopaint2.core.views.components
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class SbCheckBox extends MovieClip
	{
		private var _selected:Boolean = false;

		public static const CHANGE:String = "onChange";

		public function SbCheckBox() {
			super();

			stop();

			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownEvent );
		}

		private function onMouseDownEvent( event:MouseEvent ):void {
			_selected = !_selected;
			dispatchEvent( new Event( SbCheckBox.CHANGE ) );

			if( !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}

		private function onEnterFrame( event:Event ):void {
			if( _selected ) {

				if( currentFrame != 5 ) {
					gotoAndStop( currentFrame + 1 );
				}
				else {
					stop();
					removeEventListener( Event.ENTER_FRAME, onEnterFrame );
				}
			}
			else {

				if( currentFrame != 1 ) {
					gotoAndStop( currentFrame - 1 );
				}
				else {
					stop();
					removeEventListener( Event.ENTER_FRAME, onEnterFrame );
				}
			}
		}

		public function get selected():Boolean {
			return _selected;
		}
	}
}
