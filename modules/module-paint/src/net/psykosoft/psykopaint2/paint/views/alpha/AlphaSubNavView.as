package net.psykosoft.psykopaint2.paint.views.alpha
{

	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.slider.AlphaSlider;
	import net.psykosoft.psykopaint2.core.views.navigation.NavigationView;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class AlphaSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Pick a Brush";

		private var _alphaSlider:AlphaSlider;

		public function AlphaSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
			setLeftButton( ID_BACK, ID_BACK, ButtonIconType.BACK );
			showRightButton( false );
			setBgType( NavigationView.BG_TYPE_WOOD );

			_alphaSlider = new AlphaSlider();
			_alphaSlider.x = 1024 / 2 - _alphaSlider.width / 2;
			_alphaSlider.y = 640;
			addChild( _alphaSlider );
		}

		override protected function onDisposed():void {

		}
	}
}
