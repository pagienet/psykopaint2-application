package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selecttexture
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectTextureSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectTextureSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case SelectTextureSubNavigationView.BUTTON_LABEL_PICK_A_BRUSH:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_BRUSH ) );
					break;
				case SelectTextureSubNavigationView.BUTTON_LABEL_PICK_A_COLOR:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_COLORS ) );
					break;
				default:
					Cc.warn( this, "Cannot texturize yet, feature not implemented." );
					break;
			}
		}
	}
}
