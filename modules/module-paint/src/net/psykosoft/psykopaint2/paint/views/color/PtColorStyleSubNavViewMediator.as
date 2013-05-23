package net.psykosoft.psykopaint2.paint.views.color
{

	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class PtColorStyleSubNavViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtColorStyleSubNavView;

		[Inject]
		public var notifyColorStyleConfirmSignal:NotifyColorStyleConfirmSignal;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );

			// Post init.
			view.setAvailableColorStyles( colorStyleModule.getAvailableColorStylePresets() );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case PtColorStyleSubNavView.LBL_PICK_AN_IMAGE: {
					requestStateChange( CrStateType.STATE_PICK_IMAGE );
					break;
				}
				case PtColorStyleSubNavView.LBL_CONFIRM: {
					notifyColorStyleConfirmSignal.dispatch();
					break;
				}
				default: { // Center buttons trigger color style changes.
					notifyColorStyleChangedSignal.dispatch( label );
					break;
				}
			}
		}
	}
}
