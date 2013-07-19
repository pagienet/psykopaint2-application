package net.psykosoft.psykopaint2.core.views.popups.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class PopUpViewBase extends ViewBase
	{
		protected var _container:Sprite;
		protected var _useBlocker:Boolean = true;

		private var _blocker:Sprite;

		public function PopUpViewBase() {
			super();
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
				_blocker.graphics.beginFill( 0x000000, 0 );
				_blocker.graphics.drawRect( 0, 0, 1024, 768 );
				_blocker.graphics.endFill();
				addChild( _blocker );
			}

			_container = new Sprite();
			addChild( _container );

			layout();
		}

		override protected function onDisabled():void {

			if( _blocker ) {
				removeChild( _blocker );
				_blocker = null;
			}

			if( _container ) {
				removeChild( _container );
				_container = null;
			}
		}
	}
}
