package net.psykosoft.psykopaint2.home.views.pickimage
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class PickAUserImageViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickAUserImageView;

		[Inject]
		public var requestCropSourceImageSignal:RequestCropSourceImageSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.PICK_USER_IMAGE_DESKTOP );
			registerEnablingState( NavigationStateType.PICK_USER_IMAGE_IOS );

			// From view.
			view.imagePickedSignal.add( onImagePicked );
		}

		override public function destroy():void {
			view.imagePickedSignal.remove( onImagePicked );
			view.disable();
			view.dispose();
			super.destroy();
		}

		// -----------------------
		// From view.
		// -----------------------

		private function onImagePicked( bmd:BitmapData ):void {
			if( bmd ) requestCropSourceImageSignal.dispatch( bmd );
			else requestNavigationStateChange( NavigationStateType.PREVIOUS );
		}
	}
}
