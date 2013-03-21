package net.psykosoft.psykopaint2.app.view.painting.colorstyle
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.view.painting.colorstyle.ColorStyleView;

	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class ColorStyleViewMediator extends StarlingMediator
	{
		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var view:ColorStyleView;

		[Inject]
		public var notifyColorStyleModuleActivatedSignal:NotifyColorStyleModuleActivatedSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;

		[Inject]
		public var notifyColorStyleConfirmSignal:NotifyColorStyleConfirmSignal;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		// TODO
//		[Inject]
//		public var notifyHudToggledSignal:NotifyHudToggledSignal;

		override public function initialize():void {

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifyColorStyleModuleActivatedSignal.add( onModuleActivated );
			notifyColorStyleCompleteSignal.add( onColorStyleCompleteSignal );
			notifyColorStyleChangedSignal.add( onColorStyleChanged );
			notifyColorStyleConfirmSignal.add( confirmColorStyle );

			super.initialize();
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onApplicationStateChanged( newState:StateVO ):void {
			if( newState.name == ApplicationStateType.PAINTING_SELECT_COLORS ) {
				view.enable();
			}
			else {
				view.disable();
			}
		}

		private function onModuleActivated( bitmapData:BitmapData ):void {

			trace( this, "module activated" );

			view.resultMap = colorStyleModule.resultMap;

			// TODO
//			notifyHudToggledSignal.dispatch( new HudToggleVO( HudType.COLOR, true ) );

		}

		private function onColorStyleCompleteSignal( bitmapData:BitmapData ):void {

			trace( this, "color style complete" );

			// TODO
//			notifyHudToggledSignal.dispatch( new HudToggleVO( HudType.COLOR, false ) );

//			view.visible = false;
		}

		private function onColorStyleChanged( styleName:String ):void {
			colorStyleModule.setColorStyle( styleName );
			view.updatePreview();
		}

		private function confirmColorStyle():void {
			colorStyleModule.confirmColorStyle();
		}
	}
}
