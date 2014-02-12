package net.psykosoft.psykopaint2.home.views.home
{
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingDataSetSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestEaselUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFinalizeCropSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestOpenCroppedBitmapDataSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateCropImageSignal;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeViewDeleteModeChangedSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestLoadPaintingDataFileSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestStartNewColorPaintingSignal;
	
	import org.gestouch.events.GestureEvent;
	
	import robotlegs.bender.bundles.mvcs.Mediator;

	public class EaselViewMediator extends Mediator
	{
		[Inject]
		public var view : EaselView;

		[Inject]
		public var easelRectModel : EaselRectModel;

		[Inject]
		public var requestEaselPaintingUpdateSignal : RequestEaselUpdateSignal;

		[Inject]
		public var notifyPaintingDataRetrievedSignal : NotifyPaintingDataSetSignal;

		[Inject]
		public var requestLoadPaintingDataSignal : RequestLoadPaintingDataFileSignal;

		[Inject]
		public var requestStartNewPaintingCommand : RequestStartNewColorPaintingSignal;

		[Inject]
		public var requestNavigationStateChangeSignal : RequestNavigationStateChangeSignal;
		
		[Inject]
		public var notifyHomeViewDeleteModeChangedSignal : NotifyHomeViewDeleteModeChangedSignal;
		
		[Inject]
		public var requestUpdateCropImageSignal:RequestUpdateCropImageSignal;
		
		[Inject]
		public var notifyCropConfirmSignal:RequestFinalizeCropSignal;

		[Inject]
		public var requestOpenCroppedBitmapDataSignal:RequestOpenCroppedBitmapDataSignal;
		
		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		private var _selectedSurfaceID : uint;
		private var canOpenImageOnEasel:Boolean;

		public function EaselViewMediator()
		{
			canOpenImageOnEasel = true;
		}

		private function onEaselRectChanged() : void
		{
			easelRectModel.absoluteScreenRect = view.easelRect;
		}

		override public function initialize() : void
		{
			super.initialize();
			view.mouseEnabled = false;
			requestNavigationStateChangeSignal.add(onRequestNavigationStateChange);
			view.easelRectChanged.add(onEaselRectChanged);
			view.easelTappedSignal.add(onEaselTapped);
			requestEaselPaintingUpdateSignal.add(onEaselUpdateRequest);
			notifyPaintingDataRetrievedSignal.add(onPaintingDataRetrieved);
			notifyHomeViewDeleteModeChangedSignal.add(onDeleteModeChanged);
			requestUpdateCropImageSignal.add( updateCropSourceImage );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyCropConfirmSignal.add( onRequestFinalizeCrop );
		}

		private function onRequestNavigationStateChange(newState : String) : void
		{
			if (newState == NavigationStateType.HOME_ON_EASEL ||
				newState == NavigationStateType.HOME_PICK_SURFACE)
				view.mouseEnabled = true;
			else
				view.mouseEnabled = false;
		}

		override public function destroy() : void
		{
			super.destroy();
			requestNavigationStateChangeSignal.add(onRequestNavigationStateChange);
			view.easelRectChanged.remove(onEaselRectChanged);
			view.easelTappedSignal.remove(onEaselTapped);
			requestEaselPaintingUpdateSignal.remove(onEaselUpdateRequest);
			notifyPaintingDataRetrievedSignal.remove(onPaintingDataRetrieved);
			notifyHomeViewDeleteModeChangedSignal.remove(onDeleteModeChanged);
			requestUpdateCropImageSignal.remove( updateCropSourceImage );
			notifyGlobalGestureSignal.remove( onGlobalGesture );
			notifyCropConfirmSignal.remove( onRequestFinalizeCrop );
		}
		
		private function onDeleteModeChanged( deleteModeActive:Boolean ):void
		{
			canOpenImageOnEasel = !deleteModeActive;
			
		}
		
		private function onEaselUpdateRequest(paintingVO : PaintingInfoVO, animateIn : Boolean = false, onUploadComplete : Function = null) : void
		{
			view.setContent(paintingVO, animateIn, onUploadComplete);

			// TODO: I'm not too fond of this
			if (paintingVO.id == PaintingInfoVO.DEFAULT_VO_ID)
				_selectedSurfaceID = paintingVO.surfaceID;
		}

		
		private function updateCropSourceImage( bitmapData:BitmapData, orientation:int ):void 
		{
			view.setCropContent( bitmapData, orientation );
		}
		
		private function onPaintingDataRetrieved(data : Vector.<PaintingInfoVO>) : void
		{
			if (data.length > 0)
				view.setContent(data[0]);
		}

		private function onEaselTapped() : void
		{
			if ( canOpenImageOnEasel )
			{
				var paintingID : String = view.paintingID;
	
				if (paintingID == PaintingInfoVO.DEFAULT_VO_ID)
					requestStartNewPaintingCommand.dispatch(_selectedSurfaceID);
				else
					requestLoadPaintingDataSignal.dispatch(view.paintingID);
			}
		}
		
		private function onGlobalGesture( gestureType:String, event:GestureEvent):void
		{
			if ( gestureType == GestureType.TRANSFORM_GESTURE_BEGAN )
			{
				view.onTransformGestureBegan( event );
			} else if ( gestureType == GestureType.TRANSFORM_GESTURE_CHANGED )
			{
				view.onTransformGesture( event );
			} else if ( gestureType == GestureType.TRANSFORM_GESTURE_ENDED )
			{
				view.onTransformGestureended( event );
			}
		}

		public function onRequestFinalizeCrop():void {
			requestOpenCroppedBitmapDataSignal.dispatch( view.getCroppedImage() );
		}
	}
}
