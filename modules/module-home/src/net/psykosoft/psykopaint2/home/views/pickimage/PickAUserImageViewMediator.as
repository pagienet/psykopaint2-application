package net.psykosoft.psykopaint2.home.views.pickimage
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.configuration.CoreConfig;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyToggleLoadingMessageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCropSourceImageSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class PickAUserImageViewMediator extends MediatorBase
	{
		[Inject]
		public var view:PickAUserImageView;

		[Inject]
		public var requestCropSourceImageSignal:RequestCropSourceImageSignal;
		
		[Inject]
		public var notifyToggleLoadingMessageSignal:NotifyToggleLoadingMessageSignal;
		
		
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

		private function onImagePicked( bmd:BitmapData, orientation:int ):void {
			trace("onImagePicked "+bmd.width);
			if( bmd ) {
				
				if ( bmd.transparent )
				{
					var dummy:BitmapData = new BitmapData( bmd.width, bmd.height, false, 0xffffff );
					dummy.draw(bmd );
					bmd.dispose();
					bmd = dummy;
				}
				
				requestCropSourceImageSignal.dispatch( bmd, orientation );
			} else {
				requestNavigationStateChange( NavigationStateType.PREVIOUS );
				notifyToggleLoadingMessageSignal.dispatch(false);
			}
		}
	}
}
