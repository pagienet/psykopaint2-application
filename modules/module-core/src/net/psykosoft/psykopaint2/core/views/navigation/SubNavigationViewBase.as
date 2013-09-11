package net.psykosoft.psykopaint2.core.views.navigation
{

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;
	import net.psykosoft.psykopaint2.base.ui.components.list.HSnapList;
	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
	import net.psykosoft.psykopaint2.base.utils.misc.ClickUtil;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;

	import org.osflash.signals.Signal;

	public class SubNavigationViewBase extends ViewBase
	{
		private var _scroller:HSnapList;
		private var _navigation:NavigationView;
		private var _centerButtonData:Vector.<ISnapListData>;

		public var scrollingStartedSignal:Signal;
		public var scrollingEndedSignal:Signal;
		public var scrollerButtonClickedSignal:Signal;

		private const SCROLLER_DISTANCE_FROM_BOTTOM:uint = 45;

		public function SubNavigationViewBase() {
			super();

			scrollingStartedSignal = new Signal();
			scrollingEndedSignal = new Signal();
			scrollerButtonClickedSignal = new Signal();

			_scroller = new HSnapList();
			_scroller.setVisibleDimensions( 1024, 130 );
			_scroller.setInteractionWidth( 1024 - 280 );
//			_scroller.x = 140;
			_scroller.y = 768 - SCROLLER_DISTANCE_FROM_BOTTOM - _scroller.visibleHeight / 2;
			_scroller.itemGap = 25;
			_scroller.randomPositioningRange = 5;
			_scroller.positionManager.minimumThrowingSpeed = 15;
			_scroller.positionManager.frictionFactor = 0.70;
			_scroller.interactionManager.throwInputMultiplier = 2;
			_scroller.motionStartedSignal.add( onScrollerMotionStart );
			_scroller.motionEndedSignal.add( onScrollerMotionEnd );
			_scroller.rendererAddedSignal.add( onScrollerItemRendererAdded );
			_scroller.rendererRemovedSignal.add( onScrollerItemRendererRemoved );
//			_scroller.motionUpdatedSignal.add( onScrollerMotionUpdated );
			addChild( _scroller );
		}

		override public function dispose():void {

			_scroller.motionStartedSignal.remove( onScrollerMotionStart );
			_scroller.motionEndedSignal.remove( onScrollerMotionEnd );
			_scroller.rendererAddedSignal.remove( onScrollerItemRendererAdded );
			_scroller.rendererRemovedSignal.remove( onScrollerItemRendererRemoved );
			_scroller.dispose();
			_scroller = null;

			_centerButtonData = null;
			_navigation = null;

			super.dispose();
		}

		public function evaluateScrollingInteractionStart():void {
			_scroller.evaluateInteractionStart();
		}

		public function evaluateScrollingInteractionEnd():void {
			_scroller.evaluateInteractionEnd();
		}

		// Just for debugging, can be removed...
		/*private function onScrollerMotionUpdated():void {
			trace( ">>> SCROLLER UPDATE: " + id );
		}*/

		// ---------------------------------------------------------------------
		// SbNavigationView wrapping.
		// ---------------------------------------------------------------------

		public function setHeader( value:String ):void {
			_navigation.setHeader( value );
		}

		public function setLeftButton( id:String, label:String, iconType:String = ButtonIconType.BACK ):void {
			_navigation.setLeftButton( id, label, iconType );
		}

		public function setRightButton( id:String, label:String, iconType:String = ButtonIconType.CONTINUE ):void {
			_navigation.setRightButton( id, label, iconType );
		}

		public function showLeftButton( value:Boolean ):void {
			_navigation.showLeftButton( value );
		}

		public function showRightButton( value:Boolean ):void {
			_navigation.showRightButton( value );
		}

		public function setNavigation( value:NavigationView ):void {
			_navigation = value;
		}

		public function get navigationButtonClickedSignal():Signal {
			return _navigation.buttonClickedSignal;
		}

		// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function selectButtonWithLabel( value:String ):void {

			var i:uint;
			var buttons:Vector.<DisplayObject> = _scroller.itemRenderers;
			var numButtons:uint = buttons.length;
			var button:NavigationButton;
			for( i = 0; i < numButtons; i++ ) {
				button = buttons[ i ] as NavigationButton;
				if( button.labelText.toLowerCase() == value.toLowerCase() ) break;
				button = null;
			}

			if( !button ) return;

			unSelectAllButtons();
			button.selected = true;
			_scroller.updateItemRendererAssociatedData( button, "selected" );

			_scroller.updateAllItemRenderersFromData();
		}

		public function validateCenterButtons():void {
			if( _centerButtonData ) {
				_scroller.setDataProvider( _centerButtonData );
			}
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function createCenterButton( id:String, label:String, iconType:String = ButtonIconType.DEFAULT, rendererClass:Class = null, icon:Bitmap = null, selectable:Boolean = false ):ButtonData {
			if( !_centerButtonData ) _centerButtonData = new Vector.<ISnapListData>();
			var btnData:ButtonData = new ButtonData();
			btnData.labelText = btnData.defaultLabelText = label;
			btnData.iconType = iconType;
			btnData.iconBitmap = icon;
			btnData.selectable = selectable;
			btnData.id = id;
			btnData.itemRendererWidth = 100;
			btnData.itemRendererType = rendererClass || IconButton;
			_centerButtonData.push( btnData );
			return btnData;
		}

		protected function getItemRendererForElementWithId( id:String ):DisplayObject {
			var numData:uint = _centerButtonData.length;
			var matchingData:ButtonData;
			for( var i:uint; i < numData; i++ ) {
				var data:ButtonData = _centerButtonData[ i ] as ButtonData;
				if( data.id == id ) {
					matchingData = data;
					break;
				}
			}
			return matchingData.itemRenderer;
		}

		protected function invalidateCenterButtons():void {
			_scroller.reset();
			_centerButtonData = null;
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onButtonClicked( event:MouseEvent ):void {

			if( _scroller.isActive ) return; // Reject clicks while the scroller is moving.

			var clickedButton:NavigationButton = event.target as NavigationButton;
			if( !clickedButton ) clickedButton = event.target.parent as NavigationButton;
			if( !clickedButton ) {
				//throw new Error( "unidentified button clicked." );
				//sorry - this was too annoying for debugging:
				return;
			}

			// Deselect all buttons except the clicked one.
			if( clickedButton.selectable ) {
				selectButtonWithLabel( clickedButton.labelText );
			}

			scrollerButtonClickedSignal.dispatch( event );
		}

		private function unSelectAllButtons():void {

			var dataProvider:Vector.<ISnapListData> = _scroller.dataProvider;
			if( dataProvider ) {
				var numData:uint = dataProvider.length;
				for( var i:uint = 0; i < numData; i++ ) {
					var data:ButtonData = dataProvider[ i ] as ButtonData;
					data.selected = false;
				}
			}
			// Note, to changes to take effect visually, you need to call _scroller.refreshItemRenderers();
		}

		// ---------------------------------------------------------------------
		// Handlers.
		// ---------------------------------------------------------------------

		private function onScrollerMotionEnd():void {
			scrollingEndedSignal.dispatch();
		}

		private function onScrollerMotionStart():void {
			scrollingStartedSignal.dispatch();
		}

		private function onScrollerItemRendererAdded( renderer:DisplayObject ):void {
			renderer.addEventListener( MouseEvent.MOUSE_DOWN, onButtonClicked );
		}

		private function onScrollerItemRendererRemoved( renderer:DisplayObject ):void {
			renderer.removeEventListener( MouseEvent.MOUSE_DOWN, onButtonClicked );
		}
	}
}
