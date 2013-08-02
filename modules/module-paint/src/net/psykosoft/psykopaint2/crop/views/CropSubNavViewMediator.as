package net.psykosoft.psykopaint2.crop.views
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestFinalizeCropSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class CropSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:CropSubNavView;

		[Inject]
		public var requestFinalizeCropSignal:RequestFinalizeCropSignal;

		override public function initialize():void {
			registerView( view );
			super.initialize();
		}

		override protected function onButtonClicked( label:String ):void {
			switch( label ) {
				case CropSubNavView.LBL_PICK_AN_IMAGE: {
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.PICK_IMAGE );
					break;
				}
				case CropSubNavView.LBL_CONFIRM_CROP: {
					//TODO: blocker activation
					requestFinalizeCropSignal.dispatch();
					break;
				}
			}
		}
	}
}
