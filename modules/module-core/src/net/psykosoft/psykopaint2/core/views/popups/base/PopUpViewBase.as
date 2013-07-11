package net.psykosoft.psykopaint2.core.views.popups.base
{

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	import org.osflash.signals.Signal;

	public class PopUpViewBase extends ViewBase
	{
		public var blockerClickedSignal:Signal;

		protected var _container:Sprite;
		protected var _useBlocker:Boolean = true;

		private var _blocker:Sprite;

		public function PopUpViewBase() {
			super();
			blockerClickedSignal = new Signal();
		}

		protected function layout():void {
			_container.x = 1024 / 2 - _container.width / 2;
			_container.y = 768 / 2 - _container.height / 2;
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			if( _useBlocker ) {
				_blocker = new Sprite();
				_blocker.graphics.beginFill( 0x000000, 0.75 );
				_blocker.graphics.drawRect( 0, 0, 1024, 768 );
				_blocker.graphics.endFill();
				_blocker.addEventListener( MouseEvent.MOUSE_DOWN, onBlockerMouseDown );
				addChild( _blocker );
			}

			_container = new Sprite();
			addChild( _container );

			layout();
		}

		override protected function onDisabled():void {

			if( _blocker ) {
				removeChild( _blocker );
				_blocker.removeEventListener( MouseEvent.MOUSE_DOWN, onBlockerMouseDown );
				_blocker = null;
			}

			if( _container ) {
				removeChild( _container );
				_container = null;
			}
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onBlockerMouseDown( event:MouseEvent ):void {
			blockerClickedSignal.dispatch();
		}
	}
}
