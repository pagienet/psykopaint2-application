package net.psykosoft.psykopaint2.core.views.navigation
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;
	import net.psykosoft.psykopaint2.base.ui.components.list.HSnapList;
	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
	import net.psykosoft.psykopaint2.core.views.components.button.BitmapButton;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonData;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	
	import org.osflash.signals.Signal;

	public class SubNavigationViewBase extends ViewBase
	{
		protected var _scroller:HSnapList;
		protected var _navigation:NavigationView;
		private var _centerButtonData:Vector.<ISnapListData>;

		public var scrollingStartedSignal:Signal;
		public var scrollingEndedSignal:Signal;
		public var scrollerButtonClickedSignal:Signal;

		private const SCROLLER_DISTANCE_FROM_BOTTOM:uint = 45;
		private var _initialPositionX:Number;

		public function SubNavigationViewBase() {
			super();

			scalesToRetina = false;

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
			_initialPositionX = _scroller.positionManager.position;
		}

		public function evaluateScrollingInteractionEnd():void {
			_scroller.evaluateInteractionEnd();
		}
		
		public function evaluateScrollingInteractionUpdated():void
		{
			trace(this,"evaluateScrollingInteractionUpdated" );
			
			//_scroller.positionManager.update();
			
			//var shiftDistance:Number = Math.min(Math.abs(_initialPositionX - _scroller.positionManager.position),200);
			//_scroller.y = 768 - SCROLLER_DISTANCE_FROM_BOTTOM - _scroller.visibleHeight / 2;
		
		}

		// Just for debugging, can be removed...
		/*private function onScrollerMotionUpdated():void {
			trace( ">>> SCROLLER UPDATE: " + id );
		}*/

		public function toggleScrolling( value:Boolean ):void {
			_scroller.scrollingAllowed = value;
		}

		// ---------------------------------------------------------------------
		// SbNavigationView wrapping.
		// ---------------------------------------------------------------------

		public function setHeader( value:String ):void {
			_navigation.header.setTitle( value );
		}

		public function setLeftButton( id:String, label:String, iconType:String = ButtonIconType.BACK, showBackground:Boolean = true ):void {
			_navigation.setLeftButton( id, label, iconType, showBackground );
		}

		public function setRightButton( id:String, label:String, iconType:String = ButtonIconType.CONTINUE, labelVisible : Boolean = false ):void {
			_navigation.setRightButton( id, label, iconType, labelVisible );
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

		// type - NavigationView.BG_WOOD, etc.
		public function setBgType( type:String ):void {
			_navigation.setBgType( type );
		}

		public function getButtonIconForRightButton():Sprite {
			return _navigation.getButtonIconForRightButton();
		}

		// not exactly pretty, but hey
		public function getRightButton() : Sprite
		{
			return _navigation.getRightButton();
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

			_scroller.updateItemRenderersFromData();
		}

		public function validateCenterButtons():void {
			if( _centerButtonData ) {
				_scroller.setDataProvider( _centerButtonData );
			}
		}

		public function enableButtonWithId( id:String, enabled:Boolean ):void {

			var targetData:ButtonData;
			var dataProvider:Vector.<ISnapListData> = _scroller.dataProvider;
			if( dataProvider ) {
				var numData:uint = dataProvider.length;
				for( var i:uint = 0; i < numData; i++ ) {
					var data:ButtonData = dataProvider[ i ] as ButtonData;
					if( id.indexOf( data.id ) != -1 ) {
					    targetData = data;
						break;
					}
				}
			}

			if( !targetData ) return;

			targetData.enabled = enabled;

			_scroller.updateItemRenderersFromData();
		}
		
		public function relabelButtonWithId( id:String, newLabel:String,newIcon:String ):void {

			var targetData:ButtonData;
			var dataProvider:Vector.<ISnapListData> = _scroller.dataProvider;
			if( dataProvider ) {
				var numData:uint = dataProvider.length;
				for( var i:uint = 0; i < numData; i++ ) {
					var data:ButtonData = dataProvider[ i ] as ButtonData;
					if( id.indexOf( data.id ) != -1 ) {
					    targetData = data;
						break;
					}
				}
			}

			if( !targetData ) return;

			if (newLabel)
				targetData.labelText = newLabel;

			if (newIcon)
				targetData.iconType = newIcon;

			_scroller.updateItemRenderersFromData();
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function createCenterButton( id:String, label:String, iconType:String = ButtonIconType.DEFAULT,
											   rendererClass:Class = null, icon:Bitmap = null, selectable:Boolean = false, enabled:Boolean = true,
											   disableMouseInteractivityWhenSelected:Boolean = true, clickType:String = MouseEvent.MOUSE_UP,
												readyCallbackObject:Object= null, readyCallbackMethod:Function = null):ButtonData {
			if( !_centerButtonData ) _centerButtonData = new Vector.<ISnapListData>();
			var btnData:ButtonData = new ButtonData();
			btnData.labelText = btnData.defaultLabelText = label;
			btnData.iconType = iconType;
			btnData.disableMouseInteractivityWhenSelected = disableMouseInteractivityWhenSelected;
			btnData.iconBitmap = icon;
			btnData.selectable = selectable;
			btnData.id = id;
			btnData.itemRendererWidth = 100;
			btnData.itemRendererType = rendererClass || IconButton;
			btnData.enabled = enabled;
			btnData.clickType = clickType;
			btnData.readyCallbackObject = readyCallbackObject;
			btnData.readyCallbackMethod = readyCallbackMethod;
			
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
			if( !clickedButton ) clickedButton = event.target.parent.parent as NavigationButton;
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
			// Note, for changes to take effect visually, you need to call _scroller.refreshItemRenderers();
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
			var data:ButtonData = _scroller.getDataForRenderer( renderer );
			renderer.addEventListener( data.clickType, onButtonClicked );
			if ( data.readyCallbackObject )
			{
				data.readyCallbackMethod.apply(data.readyCallbackObject,[renderer]);
			}
		}

		private function onScrollerItemRendererRemoved( renderer:DisplayObject ):void {
			var data:ButtonData = _scroller.getDataForRenderer( renderer );
			if ( data )
			{
				renderer.removeEventListener( data.clickType, onButtonClicked );
			} else {
				trace("FIXME SubNavigationViewBase.onScrollerItemRendererRemoved");
			}
		}
		
		
	}
}
