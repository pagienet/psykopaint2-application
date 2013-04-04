package net.psykosoft.psykopaint2.app.view.painting.colorstyle
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;

	public class ColorStyleViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var colorStyleView:ColorStyleView;

		[Inject]
		public var notifyColorStyleModuleActivatedSignal:NotifyColorStyleModuleActivatedSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal:NotifyColorStyleCompleteSignal;

		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;

		[Inject]
		public var notifyColorStyleConfirmSignal:NotifyColorStyleConfirmSignal;

		// TODO
//		[Inject]
//		public var notifyHudToggledSignal:NotifyHudToggledSignal;

		override public function initialize():void {

			super.initialize();
			registerView( colorStyleView );
			registerEnablingState( ApplicationStateType.PAINTING_SELECT_COLORS );

			// From app.
			notifyColorStyleModuleActivatedSignal.add( onModuleActivated );
			notifyColorStyleCompleteSignal.add( onColorStyleCompleteSignal );
			notifyColorStyleChangedSignal.add( onColorStyleChanged );
			notifyColorStyleConfirmSignal.add( confirmColorStyle );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onModuleActivated( bitmapData:BitmapData ):void {

			trace( this, "module activated" );

			colorStyleView.resultMap = colorStyleModule.resultMap;

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
			colorStyleView.updatePreview();
		}

		private function confirmColorStyle():void {
			colorStyleModule.confirmColorStyle();
		}
	}
}
