package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import mx.modules.IModule;

	import net.psykosoft.psykopaint2.base.states.ns_state_machine;

	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestCancelCropSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetCropBackgroundSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestSetCanvasBackgroundSignal;

	use namespace ns_state_machine;

	public class CropState extends State
	{
		[Inject]
		public var requestStateChangeSignal : RequestNavigationStateChangeSignal;

		[Inject]
		public var requestOpenCroppedBitmapDataSignal : RequestOpenCroppedBitmapDataSignal;

		[Inject]
		public var requestCancelCropSignal : RequestCancelCropSignal;

		[Inject]
		public var transitionToPaintState : TransitionCropToPaintState;

		[Inject]
		public var requestSetCanvasBackgroundSignal : RequestSetCanvasBackgroundSignal;

		// to be able to forward
		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		[Inject]
		public var easelRectModel : EaselRectModel;

		[Inject]
		public var transitionCropToHomeState : TransitionCropToHomeState;

		private var _background : RefCountedTexture;

		public function CropState()
		{
		}

		[Inject]
		public function init() : void
		{
			requestSetCropBackgroundSignal.add(onRequestSetCropBackgroundSignal);
		}

		override ns_state_machine function activate(data : Object = null) : void
		{
			requestStateChangeSignal.dispatch(NavigationStateType.CROP);
			requestCancelCropSignal.add(onRequestCancelCropSignal);
			requestOpenCroppedBitmapDataSignal.add(onRequestOpenCroppedBitmapData);
		}

		private function onRequestSetCropBackgroundSignal(background : RefCountedTexture) : void
		{
			_background = background;
		}

		override ns_state_machine function deactivate() : void
		{
			requestCancelCropSignal.remove(onRequestCancelCropSignal);
			requestOpenCroppedBitmapDataSignal.remove(onRequestOpenCroppedBitmapData);
			_background = null;
		}

		private function onRequestOpenCroppedBitmapData(bitmapData : BitmapData) : void
		{
			requestSetCanvasBackgroundSignal.dispatch(_background.newReference(), easelRectModel.rect);
			stateMachine.setActiveState(transitionToPaintState, bitmapData);
		}

		private function onRequestCancelCropSignal() : void
		{
			stateMachine.setActiveState(transitionCropToHomeState);
		}
	}
}
