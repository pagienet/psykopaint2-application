package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class HomeSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:HomeSubNavView;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case HomeSubNavView.LBL_NEWS1:
//					requestStateChange( new StateVO( ApplicationStateType.SETTINGS ) ); // TODO: currently disabled
					break;
				case HomeSubNavView.LBL_NEWS2:
//					notifyPopUpDisplaySignal.dispatch( PopUpType.NO_FEATURE ); // TODO: currently disabled
					break;
				case HomeSubNavView.LBL_NEWS3:
//					requestStateChange( new StateVO( ApplicationStateType.PAINTING ) ); // TODO: currently disabled
					break;
			}
		}
	}
}
