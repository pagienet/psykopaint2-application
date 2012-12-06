package net.psykosoft.psykopaint2.view.starling.base
{

	import feathers.core.DisplayListWatcher;
	import feathers.themes.AeonDesktopTheme;

	import net.psykosoft.psykopaint2.view.starling.navigation.Navigation2dView;

	import net.psykosoft.psykopaint2.view.starling.splash.Splash2dView;

	public class StarlingRootSprite extends StarlingViewBase
	{
		protected var _feathersTheme:DisplayListWatcher;

		public function StarlingRootSprite() {

			super();

		}

		override protected function onSetup():void {

			// Define application UI theme.
			_feathersTheme = new AeonDesktopTheme( stage );

			// Initialize 2d display tree.
			addChild( new Navigation2dView() );
			addChild( new Splash2dView() );

		}
	}
}