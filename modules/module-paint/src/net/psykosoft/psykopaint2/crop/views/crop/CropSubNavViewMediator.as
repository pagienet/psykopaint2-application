package net.psykosoft.psykopaint2.crop.views.crop
{

	import net.psykosoft.psykopaint2.core.signals.NotifyToggleLoadingMessageSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFinalizeCropSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.crop.signals.RequestCancelCropSignal;

	public class CropSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:CropSubNavView;

		[Inject]
		public var requestFinalizeCropSignal:RequestFinalizeCropSignal;

		[Inject]
		public var requestCancelCropSignal : RequestCancelCropSignal;

		[Inject]
		public var notifyToggleLoadingMessageSignal:NotifyToggleLoadingMessageSignal;
		
		override public function initialize():void {
			registerView( view );
			super.initialize();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case CropSubNavView.ID_PICK_AN_IMAGE:
					requestCancelCropSignal.dispatch();
					break;
				case CropSubNavView.ID_CONFIRM_CROP:
					//TODO: blocker activation
					notifyToggleLoadingMessageSignal.dispatch(true);
					requestFinalizeCropSignal.dispatch();
				    break;
			}
		}
	}
}
