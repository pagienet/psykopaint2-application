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
			renderer.sourceTextureAlpha = 1 - value;
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
