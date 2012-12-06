package net.psykosoft.psykopaint2.view.starling.base
{

	import feathers.core.DisplayListWatcher;

	import net.psykosoft.psykopaint2.view.starling.splash.Splash2dView;

	public class StarlingRootSprite extends StarlingViewBase
	{
		protected var _feathersTheme:DisplayListWatcher;

		public function StarlingRootSprite() {

			super();

		}

		override protected function onSetup():void {

			// Define application UI theme.
//			_feathersTheme = new MetalWorksMobileTheme( stage );

			// Add child views.
			addChild( new Splash2dView() );

		}
	}
}