package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestSourceImageSetSignal;

	public class PickAnImageViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickAnImageView;

		[Inject]
		public var requestSourceImageSetSignal:RequestSourceImageSetSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.PICK_IMAGE );

			// From view.
			view.imagePickedSignal.add( onImagePicked );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onImagePicked( bmd:BitmapData ):void {
			if( bmd ) {
				// Show navigation.
				requestNavigationToggleSignal.dispatch( 1 );
				// Change drawing core state.
				requestSourceImageSetSignal.dispatch( bmd ); // Goes through crop, color style, etc...
	//			notifyColorStyleCompleteSignal.dispatch( bmd ); // Goes straight to paint mode.
			}
			else {
				requestStateChange( StateType.PREVIOUS );
			}
		}
	}
}
