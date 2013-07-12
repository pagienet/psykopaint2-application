package net.psykosoft.psykopaint2.paint.views.crop
{

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCropModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectInfoSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselRectInfoSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class CropViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CropView;

		[Inject]
		public var notifyCropModuleActivatedSignal:NotifyCropModuleActivatedSignal;

		[Inject]
		public var notifyCropCompleteSignal:NotifyCropCompleteSignal;

		[Inject]
		public var notifyCropConfirmSignal:NotifyCropConfirmSignal;

		[Inject]
		public var requestEaselRectInfoSignal:RequestEaselRectInfoSignal;

		[Inject]
		public var notifyEaselRectInfoSignal:NotifyEaselRectInfoSignal;

		private var _sourceMap:BitmapData;
		private var _waitingForEaselRect:Boolean;
		
		override public function initialize():void {

			super.initialize();
			registerView( view );
			registerEnablingState( StateType.CROP );

			// From app.
			notifyCropModuleActivatedSignal.add( onCropModuleActivated );
			notifyCropConfirmSignal.add( onCropConfirmed );
			notifyEaselRectInfoSignal.add( onEaselRectInfoRetrieved );
		}

		// -----------------------
		// From app.
		// -----------------------

		public function onCropConfirmed():void {
			notifyCropCompleteSignal.dispatch( view.renderPreviewToBitmapData() );
		}

		private function onCropModuleActivated( bitmapData:BitmapData ):void {
			trace( this, "onCropModuleActivated" );
			_sourceMap = bitmapData;
			_waitingForEaselRect = true;
			requestEaselRectInfoSignal.dispatch();
		}

		private function onEaselRectInfoRetrieved( rect:Rectangle ):void {
			trace( this, "onEaselRectInfoRetrieved" );
			if( _waitingForEaselRect ) {
				view.easelRect = rect;
				view.sourceMap = _sourceMap;
				_waitingForEaselRect = false;
			}
		}
	}
}
