package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	public class HomeSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:HomeSubNavView;

		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Uncomment for faster login views dev.
			requestShowPopUpSignal.dispatch( PopUpType.LOGIN );
		}
	}
}
