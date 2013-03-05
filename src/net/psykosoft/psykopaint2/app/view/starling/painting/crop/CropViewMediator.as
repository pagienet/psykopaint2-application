package net.psykosoft.psykopaint2.app.view.starling.painting.crop
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.data.types.StateType;

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;

	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyStateChangedSignal;
	import net.psykosoft.psykopaint2.app.view.starling.painting.crop.CropView;

	import net.psykosoft.psykopaint2.core.drawing.modules.CropModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class CropViewMediator extends StarlingMediator
	{
		[Inject]
		public var cropModule:CropModule;

		[Inject]
		public var view:CropView;

		[Inject]
		public var notifyCropModuleActivatedSignal:NotifyCropModuleActivatedSignal;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;

		[Inject]
		public var notifyStateChangedSignal:NotifyStateChangedSignal;

		override public function initialize():void {

			// From app.
			notifyStateChangedSignal.add( onApplicationStateChanged );
			notifyCropModuleActivatedSignal.add( onModuleActivated );
			notifyCropConfirmSignal.add( doCrop );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onApplicationStateChanged( newState:StateVO ):void {
			if( newState.name == StateType.PAINTING_CROP_IMAGE ) {
				view.enable();
			}
			else {
				view.disable();
			}
		}

		public function doCrop():void {
			if( view.visible ) cropModule.crop( view.cropMatrix );
		}

		private function onModuleActivated( bitmapData:BitmapData ):void {
			view.sourceMap = bitmapData;
		}
	}
}
