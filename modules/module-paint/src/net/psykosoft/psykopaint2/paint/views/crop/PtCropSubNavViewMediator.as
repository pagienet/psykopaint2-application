package net.psykosoft.psykopaint2.paint.views.crop
{

	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class PtCropSubNavViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtCropSubNavView;

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
				case PtCropSubNavView.LBL_PICK_AN_IMAGE: {
					requestStateChange( CrStateType.STATE_PICK_IMAGE );
					break;
				}
				case PtCropSubNavView.LBL_CONFIRM_CROP: {
					notifyCropConfirmSignal.dispatch();
					break;
				}
			}
		}
	}
}
