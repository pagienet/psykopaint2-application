package net.psykosoft.psykopaint2.paint.views.alpha
{

	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class AlphaSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:AlphaSubNavView;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var navigationCanHideWithGesturesSignal:NavigationCanHideWithGesturesSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// From view.
			view.viewWantsToChangeAlphaSignal.add( onViewWantsToChangeAlpha );
			view.addEventListener( MouseEvent.MOUSE_DOWN, onViewMouseDown );
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
		}

		override public function destroy():void {
			super.destroy();
			view.viewWantsToChangeAlphaSignal.remove( onViewWantsToChangeAlpha );
			view.removeEventListener( MouseEvent.MOUSE_DOWN, onViewMouseDown );
			if( view.stage && view.stage.hasEventListener( MouseEvent.MOUSE_UP ) )
				view.stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewMouseDown( event:MouseEvent ):void {
			navigationCanHideWithGesturesSignal.dispatch( false );
			view.stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}

		private function onMouseUp( event:MouseEvent ):void {
			navigationCanHideWithGesturesSignal.dispatch( true );
			view.stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}

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
