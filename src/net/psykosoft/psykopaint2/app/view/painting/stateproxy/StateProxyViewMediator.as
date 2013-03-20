package net.psykosoft.psykopaint2.app.view.painting.stateproxy
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.signal.requests.RequestAppStateUpdateFromCoreModuleActivationSignal;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.CropModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.drawing.modules.SmearModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifySmearModuleActivatedSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class StateProxyViewMediator extends StarlingMediator
	{
		[Inject]
		public var requestAppStateUpdateFromCoreModuleActivationSignal:RequestAppStateUpdateFromCoreModuleActivationSignal;

		// ---------------------------------------------------------------------
		// Module activation signals.
		// ---------------------------------------------------------------------

		[Inject]
		public var notifyCropModuleActivatedSignal:NotifyCropModuleActivatedSignal;

		[Inject]
		public var notifyColorStyleModuleActivatedSignal:NotifyColorStyleModuleActivatedSignal;

		[Inject]
		public var notifyPaintModuleActivatedSignal:NotifyPaintModuleActivatedSignal;

		[Inject]
		public var notifySmearModuleActivatedSignal:NotifySmearModuleActivatedSignal;

		// ---------------------------------------------------------------------
		// Modules.
		// ---------------------------------------------------------------------

		[Inject]
		public var paintModule:PaintModule;

		[Inject]
		public var cropModule:CropModule;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var smearModule:SmearModule;

		override public function initialize():void {

			// From core.
			// Associates drawing core module activation to application states ( listens to the core ).
			notifyCropModuleActivatedSignal.add( onCropModuleActivated );
			notifyColorStyleModuleActivatedSignal.add( onColorStyleModuleActivated );
			notifyPaintModuleActivatedSignal.add( onPaintModuleActivated );
			notifySmearModuleActivatedSignal.add( onSmearModuleActivated );

			super.initialize();
		}

		private function onPaintModuleActivated():void {
			requestAppStateUpdateFromCoreModuleActivationSignal.dispatch( paintModule );
		}

		private function onColorStyleModuleActivated( image:BitmapData ):void {
			requestAppStateUpdateFromCoreModuleActivationSignal.dispatch( colorStyleModule );
		}

		private function onCropModuleActivated( image:BitmapData ):void {
			requestAppStateUpdateFromCoreModuleActivationSignal.dispatch( cropModule );
		}

		private function onSmearModuleActivated():void {
			requestAppStateUpdateFromCoreModuleActivationSignal.dispatch( smearModule );
		}
	}
}
