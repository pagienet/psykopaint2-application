package net.psykosoft.psykopaint2.core.views.popups.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;

	public class PopUpViewBase extends ViewBase
	{
		protected var _container:Sprite;

		public function PopUpViewBase() {
			super();
		}

		protected function layout():void {
			_container.x = 1024 / 2 - _container.width / 2;
			_container.y = 768 / 2 - _container.height / 2;
		}

		// ---------------------------------------------------------------------
		// Methods called by PopUpManagerView
		// ---------------------------------------------------------------------

		public function onAnimatedIn():void {
			// To override...
		}

		public function onGoingToAnimateIn():void {
			// To override...
		}

		public function onGoingToAnimateOut():void {
			// To override...
		}

		public function onAnimatedOut():void {
			// To override...
		}

		public function onBlockerClicked():void {
			// To override...
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			_container = new Sprite();
			addChild( _container );

			layout();
		}

		override protected function onDisabled():void {

			if( _container ) {
				removeChild( _container );
				_container = null;
			}
		}
	}
}
