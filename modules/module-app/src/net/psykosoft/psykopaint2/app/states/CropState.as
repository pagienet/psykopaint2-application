package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;

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

		// to be able to forward
		[Inject]
		public var requestSetCropBackgroundSignal : RequestSetCropBackgroundSignal;

		[Inject]
		public var transitionCropToHomeState : TransitionCropToHomeState;

		private var _background : RefCountedTexture;

		public function CropState()
		{
		}

		[PostConstruct]
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
			if (_background)
				_background.dispose();

			if (background)
				_background = background.newReference();
			else
				_background = null;
		}

		override ns_state_machine function deactivate() : void
		{
			requestCancelCropSignal.remove(onRequestCancelCropSignal);
			requestOpenCroppedBitmapDataSignal.remove(onRequestOpenCroppedBitmapData);
			_background.dispose();
			_background = null;
		}

		private function onRequestOpenCroppedBitmapData(bitmapData : BitmapData) : void
		{
			stateMachine.setActiveState(transitionToPaintState, {bitmapData: bitmapData, background: _background.newReference()});
		}

		private function onRequestCancelCropSignal() : void
		{
			stateMachine.setActiveState(transitionCropToHomeState);
		}
	}
}
