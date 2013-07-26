package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.list.HSnapList;
	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbIconButton;

	import org.osflash.signals.Signal;

	public class SubNavigationViewBase extends ViewBase
	{
		protected var _scroller:HSnapList;

		public var navigation:SbNavigationView;

		public var scrollingStartedSignal:Signal;
		public var scrollingEndedSignal:Signal;
		public var scrollerButtonClickedSignal:Signal;

		private const SCROLLER_DISTANCE_FROM_BOTTOM:uint = 70;

		// Used for debugging, can be removed...
		public var id:String = "notSet";

		public function SubNavigationViewBase() {
			super();

			scrollingStartedSignal = new Signal();
			scrollingEndedSignal = new Signal();
			scrollerButtonClickedSignal = new Signal();

			_scroller = new HSnapList();
			_scroller.id = id;
			_scroller.setVisibleDimensions( 1024, 130 );
			_scroller.setInteractionWidth( 1024 - 280 );
//			_scroller.x = 140;
			_scroller.y = 768 - SCROLLER_DISTANCE_FROM_BOTTOM - _scroller.visibleHeight / 2;
			_scroller.itemGap = 35;
			_scroller.positionManager.minimumThrowingSpeed = 15;
			_scroller.positionManager.frictionFactor = 0.70;
			_scroller.interactionManager.throwInputMultiplier = 2;
			_scroller.motionStartedSignal.add( onCenterScrollerMotionStart );
			_scroller.motionEndedSignal.add( onCenterScrollerMotionEnd );
			_scroller.rendererAddedSignal.add( onCenterScrollerItemRendererAdded );
			_scroller.rendererRemovedSignal.add( onCenterScrollerItemRendererRemoved );
			addChild( _scroller );
		}

		// ---------------------------------------------------------------------
		// ViewBase overrides.
		// ---------------------------------------------------------------------

		/*override protected function onDisabled():void {
			_scroller.releaseRenderers();
		}*/

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function evaluateScrollingInteractionStart():void {
			_scroller.evaluateInteractionStart();
		}

		public function evaluateScrollingInteractionEnd():void {
			_scroller.evaluateInteractionEnd();
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function createCenterButtonData( dataSet:Vector.<ISnapListData>, label:String, iconType:String = ButtonIconType.DEFAULT, rendererClass:Class = null, icon:Bitmap = null ):void {
			var btnData:ButtonData = new ButtonData();
			btnData.labelText = label;
			btnData.iconType = iconType;
			btnData.iconBitmap = icon;
			btnData.itemRendererWidth = 100;
			btnData.itemRendererType = rendererClass || SbIconButton;
			dataSet.push( btnData );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onButtonClicked( event:MouseEvent ):void {
			if( _scroller.isActive ) return; // Reject clicks while the scroller is moving.
			scrollerButtonClickedSignal.dispatch( event );
		}

		// ---------------------------------------------------------------------
		// Handlers.
		// ---------------------------------------------------------------------

		private function onCenterScrollerMotionEnd():void {
			scrollingEndedSignal.dispatch();
		}

		private function onCenterScrollerMotionStart():void {
			scrollingStartedSignal.dispatch();
		}

		private function onCenterScrollerItemRendererAdded( renderer:DisplayObject ):void {
			renderer.addEventListener( MouseEvent.CLICK, onButtonClicked );
		}

		private function onCenterScrollerItemRendererRemoved( renderer:DisplayObject ):void {
			renderer.removeEventListener( MouseEvent.CLICK, onButtonClicked );
		}
	}
}
