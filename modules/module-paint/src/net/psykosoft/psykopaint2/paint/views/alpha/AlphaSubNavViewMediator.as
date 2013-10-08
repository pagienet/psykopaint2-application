package net.psykosoft.psykopaint2.paint.views.alpha
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class AlphaSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:AlphaSubNavView;

		[Inject]
		public var renderer:CanvasRenderer;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From view.
			view.viewWantsToChangeAlphaSignal.add( onViewWantsToChangeAlpha );

			// From app.

		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			view.setAlpha( 1 - renderer.sourceTextureAlpha );
		}

		override public function destroy():void {
			super.destroy();
			view.viewWantsToChangeAlphaSignal.remove( onViewWantsToChangeAlpha );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewWantsToChangeAlpha( value:Number ):void {
			// The incoming slider value is 0 at left and 1 at right.
			// Here it is split to control 2 variables:
			// value - 0    0.5   1
			// photo - 1    1     0
			// paint - 0    1     1
			renderer.sourceTextureAlpha = value < 0.5 ? 1 : 1 - ( value - 0.5 ) / 0.5;
			renderer.paintAlpha = value > 0.5 ? 1 : value / 0.5;
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case AlphaSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					break;
			}
		}
	}
}
