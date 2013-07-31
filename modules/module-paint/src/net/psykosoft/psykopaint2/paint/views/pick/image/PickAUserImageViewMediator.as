package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSourceImageSetSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

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
			if( bmd ) requestSourceImageSetSignal.dispatch( bmd );
			else requestStateChange__OLD_TO_REMOVE( NavigationStateType.PREVIOUS );
		}
	}
}
