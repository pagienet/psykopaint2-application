package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestSourceImageSetSignal;

	public class PickAUserImageViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickAUserImageView;

		[Inject]
		public var requestSourceImageSetSignal:RequestSourceImageSetSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			registerEnablingState( StateType.PICK_USER_IMAGE_DESKTOP );

			// From view.
			view.imagePickedSignal.add( onImagePicked );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onImagePicked( bmd:BitmapData ):void {
			if( bmd ) requestSourceImageSetSignal.dispatch( bmd );
			else requestStateChange( StateType.PREVIOUS );
		}
	}
}
