package net.psykosoft.psykopaint2.home.views.pickimage
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.home.views.pickimage.PickAUserImageView;

	public class PickAUserImageViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickAUserImageView;

		[Inject]
		public var requestCropSourceImageSignal:RequestCropSourceImageSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.PICK_USER_IMAGE_DESKTOP );

			// From view.
			view.imagePickedSignal.add( onImagePicked );
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onImagePicked( bmd:BitmapData ):void {
			if( bmd ) requestCropSourceImageSignal.dispatch( bmd );
			else requestStateChange__OLD_TO_REMOVE( NavigationStateType.PREVIOUS );
		}
	}
}
