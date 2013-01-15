package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectimage
{

	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.requests.RequestReadyToPaintImagesSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectImageSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectImageSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var requestReadyToPaintImagesSignal:RequestReadyToPaintImagesSignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case SelectImageSubNavigationView.BUTTON_LABEL_NEW_PAINTING:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_NEW ) );
					break;
				case SelectImageSubNavigationView.BUTTON_LABEL_FACEBOOK:
					requestStateChangeSignal.dispatch( new StateVO( States.FEATURE_NOT_IMPLEMENTED ) );
					break;
				case SelectImageSubNavigationView.BUTTON_LABEL_CAMERA:
					requestStateChangeSignal.dispatch( new StateVO( States.FEATURE_NOT_IMPLEMENTED ) );
					break;
				case SelectImageSubNavigationView.BUTTON_LABEL_READY_TO_PAINT:
					requestReadyToPaintImagesSignal.dispatch();
					break;
				case SelectImageSubNavigationView.BUTTON_LABEL_YOUR_PHOTOS:
					if( Settings.RUNNING_ON_iPAD ) {
						requestStateChangeSignal.dispatch( new StateVO( States.FEATURE_NOT_IMPLEMENTED ) );
					}
					else {
						requestStateChangeSignal.dispatch( new StateVO( States.FEATURE_NOT_AVAILABLE_ON_THIS_PLATFORM ) );
					}
					break;
			}
		}
	}
}
