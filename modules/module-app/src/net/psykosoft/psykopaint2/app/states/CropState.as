package net.psykosoft.psykopaint2.app.states
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import net.psykosoft.psykopaint2.base.states.State;
	import net.psykosoft.psykopaint2.base.states.ns_state_machine;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.CameraRollImageOrientation;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedRectTexture;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestCancelCropSignal;
	import net.psykosoft.psykopaint2.crop.signals.RequestSetCropBackgroundSignal;

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
		public var transitionCropToHomeState : TransitionCropToHomeState;

		private var _background : RefCountedRectTexture;

		public function CropState()
		{
		}

		/**
		 * @param data An object:
		 * - bitmapData : BitmapDAta containing the image to be cropped
		 * - background : RefCountedTexture containing the background image
		 */
		override ns_state_machine function activate(data : Object = null) : void
		{
			
			var bitmapData : BitmapData = BitmapData(data.bitmapData);
			_background = RefCountedRectTexture(data.background);

			requestCancelCropSignal.add(onRequestCancelCropSignal);
			requestOpenCroppedBitmapDataSignal.add(onRequestOpenCroppedBitmapData);
			/*
			if (data.orientation == CameraRollImageOrientation.ROTATION_0 && BitmapDataUtils.aspectRatioMatches(bitmapData, CoreSettings.STAGE_WIDTH / CoreSettings.STAGE_HEIGHT))
				advanceDirectly(bitmapData);
			else
			*/
			requestStateChangeSignal.dispatch(NavigationStateType.CROP);
		}

		private function advanceDirectly(bitmapData : BitmapData) : void
		{
			// TODO: dispatch a special kind of CROP state, to hide the menu?
			// or, have the crop module decide what to do?
			requestStateChangeSignal.dispatch(NavigationStateType.CROP_SKIP);

			if (bitmapData.width != CoreSettings.STAGE_WIDTH || bitmapData.height != CoreSettings.STAGE_HEIGHT) {
				var newBitmapData : BitmapData = new TrackedBitmapData(CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT, false);
				var matrix : Matrix = new Matrix(CoreSettings.STAGE_WIDTH/bitmapData.width, 0, 0, CoreSettings.STAGE_HEIGHT/bitmapData.height);
				newBitmapData.draw(bitmapData, matrix, null, null, null, true);
				bitmapData.dispose();
				bitmapData = newBitmapData;
			}

			onRequestOpenCroppedBitmapData(bitmapData);
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
