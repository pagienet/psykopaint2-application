package net.psykosoft.psykopaint2.paint.views.color
{

	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class ColorStyleSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:ColorStyleSubNavView;

		[Inject]
		public var notifyColorStyleConfirmSignal:NotifyColorStyleConfirmSignal;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Post init.
			view.setAvailableColorStyles( colorStyleModule.getAvailableColorStylePresets() );
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case ColorStyleSubNavView.ID_PICK_AN_IMAGE: {
					requestNavigationStateChange( NavigationStateType.PICK_IMAGE );
					break;
				}
				case ColorStyleSubNavView.ID_CONFIRM: {
					notifyColorStyleConfirmSignal.dispatch();
					break;
				}
				default: { // Center buttons trigger color style changes.
					notifyColorStyleChangedSignal.dispatch( id );
					break;
				}
			}
		}
	}
}
