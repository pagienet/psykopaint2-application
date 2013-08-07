package net.psykosoft.psykopaint2.configuration
{

	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;
	import net.psykosoft.psykopaint2.crop.signals.DestroyCropModuleCommand;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCameraFlipRequest;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCameraSnapshotRequest;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleDestroyedSignal;
	import net.psykosoft.psykopaint2.crop.signals.NotifyCropModuleSetUpSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestCancelCropSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestDestroyCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetCropBackgroundSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetupCropModuleSignal;
	import net.psykosoft.psykopaint2.crop.signals.SetupCropModuleCommand;
	import net.psykosoft.psykopaint2.crop.views.CropSubNavView;
	import net.psykosoft.psykopaint2.crop.views.CropSubNavViewMediator;
	import net.psykosoft.psykopaint2.crop.views.CropView;
	import net.psykosoft.psykopaint2.crop.views.CropViewMediator;
	import net.psykosoft.psykopaint2.paint.signals.RequestClosePaintViewSignal;
	import net.psykosoft.psykopaint2.crop.views.pick.image.CaptureImageSubNavView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.CaptureImageSubNavViewMediator;
	import net.psykosoft.psykopaint2.crop.views.pick.image.CaptureImageView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.CaptureImageViewMediator;
	import net.psykosoft.psykopaint2.crop.views.pick.image.ConfirmCaptureImageSubNavView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.ConfirmCaptureImageSubNavViewMediator;
	import net.psykosoft.psykopaint2.crop.views.pick.image.PickAUserImageView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.PickAUserImageViewMediator;
	import net.psykosoft.psykopaint2.crop.views.pick.image.PickAnImageSubNavView;
	import net.psykosoft.psykopaint2.crop.views.pick.image.PickAnImageSubNavViewMediator;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IInjector;

	public class CropConfig
	{
		private var _injector:IInjector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function CropConfig( injector:IInjector ) {
			super();

			_injector = injector;
			_mediatorMap = _injector.getInstance( IMediatorMap );
			_commandMap = _injector.getInstance( ISignalCommandMap );

			mapMediators();
			mapCommands();
			mapNotifications();
			mapSingletons();
			mapServices();
			mapModels();
		}

		public function get injector():IInjector {
			return _injector;
		}

		// -----------------------
		// Models.
		// -----------------------

		private function mapModels():void {

		}

		// -----------------------
		// Services.
		// -----------------------

		private function mapServices():void {


		}

		// -----------------------
		// Singletons.
		// -----------------------

		private function mapSingletons():void {

		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications():void {
			_injector.map( NotifyCameraSnapshotRequest ).asSingleton();
			_injector.map( NotifyCameraFlipRequest ).asSingleton();
			_injector.map( RequestOpenCroppedBitmapDataSignal ).asSingleton();
			_injector.map( RequestUpdateCropImageSignal ).asSingleton();
			_injector.map( NotifyCropModuleSetUpSignal ).asSingleton();
			_injector.map( NotifyCropModuleDestroyedSignal ).asSingleton();
			_injector.map( RequestCancelCropSignal ).asSingleton();
			_injector.map( RequestSetCropBackgroundSignal ).asSingleton();
			_injector.map( RequestClosePaintViewSignal ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {

			_commandMap.map( RequestSetupCropModuleSignal ).toCommand( SetupCropModuleCommand );
			_commandMap.map( RequestDestroyCropModuleSignal ).toCommand( DestroyCropModuleCommand );
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( CropSubNavView ).toMediator( CropSubNavViewMediator );
			_mediatorMap.map( CropView ).toMediator( CropViewMediator );
			_mediatorMap.map( PickAnImageSubNavView ).toMediator( PickAnImageSubNavViewMediator );
			_mediatorMap.map( PickAUserImageView ).toMediator( PickAUserImageViewMediator );
			_mediatorMap.map( CaptureImageSubNavView ).toMediator( CaptureImageSubNavViewMediator );
			_mediatorMap.map( ConfirmCaptureImageSubNavView ).toMediator( ConfirmCaptureImageSubNavViewMediator );
			_mediatorMap.map( CaptureImageView ).toMediator( CaptureImageViewMediator );
		}
	}
}
