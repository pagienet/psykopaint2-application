package net.psykosoft.psykopaint2.paint.views.pick
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.CrStateType;

	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.requests.PtRequestSourceImageSetSignal;

	public class PtPickAnImageViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtPickAnImageView;

		[Inject]
		public var requestSourceImageSetSignal:PtRequestSourceImageSetSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( CrStateType.STATE_PICK_IMAGE );

			// From view.
			view.imagePickedSignal.add( onImagePicked );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onImagePicked( bmd:BitmapData ):void {
			if( bmd ) {
				requestSourceImageSetSignal.dispatch( bmd ); // Goes through crop, color style, etc...
			//	notifyColorStyleCompleteSignal.dispatch( bmd ); // Goes straight to paint mode.
			}
			else {
				requestStateChange( CrStateType.STATE_PREVIOUS );
			}
		}
	}
}
