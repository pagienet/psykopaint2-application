package net.psykosoft.psykopaint2.paint.views.crop
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class CropSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CropSubNavView;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;

		override public function initialize():void {
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case CropSubNavView.LBL_PICK_AN_IMAGE: {
					requestStateChange( StateType.STATE_PICK_IMAGE );
					break;
				}
				case CropSubNavView.LBL_CONFIRM_CROP: {
					notifyCropConfirmSignal.dispatch();
					break;
				}
			}
		}
	}
}
