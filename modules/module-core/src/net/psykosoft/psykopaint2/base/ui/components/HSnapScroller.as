package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.base.utils.ui.ScrollInteractionManager;
	import net.psykosoft.psykopaint2.base.utils.ui.SnapPositionManager;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import org.osflash.signals.Signal;

	/*
	* Adds elements to a container which can be scrolled horizontally.
	* The scrolling is based on snap points. This class doesn't actually add the snap and is expected to be overriden in that sense.
	* */
	public class HSnapScroller extends Sprite
	{
		protected var _interactionManager:ScrollInteractionManager;
		protected var _positionManager:SnapPositionManager;
		protected var _container:Sprite;
		protected var _active:Boolean;
		protected var _minContentX:Number = 0;
		protected var _maxContentX:Number = 0;
		protected var _visibleWidth:Number;
		protected var _visibleHeight:Number;
		protected var _interactionWidth:Number;

		public var scrollingAllowed:Boolean = true;
		public var motionStartedSignal:Signal;
		public var motionEndedSignal:Signal;
		public var motionUpdatedSignal:Signal;

		// Used for debugging, can be removed...
		public var id:String;

		public function HSnapScroller() {
			super();

			_positionManager = new SnapPositionManager();
			_interactionManager = new ScrollInteractionManager( _positionManager );
			_interactionManager.useDetailedDelta = false;

			motionStartedSignal = new Signal();
			motionEndedSignal = new Signal();
			motionUpdatedSignal = new Signal();

			_container = new Sprite();
			_container.cacheAsBitmap = true; // TODO: wouldn't it make more sense to only set cache as bitmap to true after all the children have been added to the container?
			super.addChild( _container );

			setVisibleDimensions( 800, 100 );

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			reset();
		}

		public function dispose():void {

			stopEnterframe();

			_positionManager.motionEndedSignal.remove( onPositionManagerMotionEnded );
			_positionManager.dispose();
			_positionManager = null;

			_interactionManager.dispose();
			_interactionManager = null;

		}

		private function initialize():void {
//			scrollRect = new Rectangle( visibleWidth, visibleHeight );
			_interactionManager.stage = stage;
			_positionManager.motionEndedSignal.add( onPositionManagerMotionEnded );
			_interactionManager.scrollInputMultiplier = 1 / CoreSettings.GLOBAL_SCALING;
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function reset():void {

			trace( this, "RESET" );

			_positionManager.reset();
			_minContentX = 0;
			_maxContentX = 0;
			_container.x = 0;

			// TODO: virtual lists shouldn't have this line, but non virtual extensors of this class might.
//			_container.removeChildren();
		}

		public function dock():void {
			_positionManager.snapAtIndexWithoutEasing( 0 );
			refreshToPosition();
		}

		public function refreshToPosition():void {
			_container.x = _visibleWidth / 2 - _positionManager.position;
		}

		override public function addChild( value:DisplayObject ):DisplayObject {
			_container.addChild( value );
			return value;
		}

		public function invalidateContent():void {

			// Add snap points for each child at its position.
			var len:uint = _container.numChildren;
			for( var i:uint; i < len; i++ ) {
				var child:DisplayObject = _container.getChildAt( i ) as DisplayObject;
				evaluateDimensionsFromItemPositionAndWidth( child.x, child.width );
				evaluateNewSnapPointFromPosition( child.x );
			}

			containEdgeSnapPoints();
			dock();
		}

		public function evaluateInteractionStart():void {
			trace( this, "evaluateInteractionStart()" );
			if( !scrollingAllowed ) return;
			if( _container.numChildren == 0 ) return;
			if( !mouseHitsInteractiveArea() ) return;
			_interactionManager.startInteraction();
			startEnterframe();
		}

		public function evaluateInteractionEnd():void {
			trace( this, "evaluateInteractionEnd()" );
			if( !_active ) return;
			_interactionManager.stopInteraction();
		}

		public function setVisibleDimensions( width:Number, height:Number ):void {
			_visibleWidth = _interactionWidth = width;
			_visibleHeight = height;
		}

		public function setInteractionWidth( value:Number ):void {
			_interactionWidth = value;
		}

		// -----------------------
		// Getters.
		// -----------------------

		override public function get height():Number {
			return _visibleHeight;
		}

		override public function get width():Number {
			return _visibleWidth;
		}

		public function get contentWidth():Number {
			return _maxContentX - _minContentX;
		}

		public function get minWidth():Number {
			return Math.min( _visibleWidth, width );
		}

		public function get maxWidth():Number {
			return Math.max( _visibleWidth, width );
		}

		public function get container():Sprite {
			return _container;
		}

		public function get isActive():Boolean {
			return _active;
		}

		public function get positionManager():SnapPositionManager {
			return _positionManager;
		}

		public function get interactionManager():ScrollInteractionManager {
			return _interactionManager;
		}

		public function get visibleHeight():Number {
			return _visibleHeight;
		}

		public function get visibleWidth():Number {
			return _visibleWidth;
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function onUpdate():void {
			// Override.
		}

		protected function evaluateNewSnapPointFromPosition( px:Number ):void {
			_positionManager.pushSnapPoint( px );
		}

		protected function evaluateDimensionsFromItemPositionAndWidth( itemPosition:Number, itemWidth:Number, offset:Number = 0 ):void {
			var minX:Number = offset + itemPosition - itemWidth / 2; // Note: assumes elements will be registered at their center
			var maxX:Number = offset + itemPosition + itemWidth / 2;
			if( minX < _minContentX ) _minContentX = minX;
			if( maxX > _maxContentX ) _maxContentX = maxX;
		}

		protected function containEdgeSnapPoints():void {

			// If scrollable content is smaller than visible width, just need one snap point.
			if( contentWidth < _visibleWidth ) {
				_positionManager.reset();
				_positionManager.pushSnapPoint( contentWidth / 2 );
				return;
			}

			// Sweep snap points looking for near edge positions.
			var len:uint = _positionManager.numSnapPoints;
			var leftEdgeSnapPointMatched:Boolean = false;
			var rightEdgeSnapPointMatched:Boolean = false;
			var minAllowed:Number = _interactionWidth / 2;
			var maxAllowed:Number = contentWidth - _interactionWidth / 2;
			for( var i:uint; i < len; i++ ) {

				var snapPoint:Number = _positionManager.getSnapPointAtIndex( i );

				// Left containment.
				if( snapPoint < minAllowed ) {
					if( leftEdgeSnapPointMatched ) {
						_positionManager.removeSnapPointAtIndex( i );
						i--; len--;
						continue;
					}
					else {
						_positionManager.updateSnapPointAtIndex( i, minAllowed );
						leftEdgeSnapPointMatched = true;
					}
				}

				// Right containment.
				if( snapPoint > maxAllowed ) {
					if( rightEdgeSnapPointMatched ) {
						_positionManager.removeSnapPointAtIndex( i );
						i--; len--;
						continue;
					}
					else {
						_positionManager.updateSnapPointAtIndex( i, maxAllowed );
						rightEdgeSnapPointMatched = true;
					}
				}
			}
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function mouseHitsInteractiveArea():Boolean {

			if( !stage ) return false;

			var topLeft:Point = new Point( 0, 0 );
			var bottomRight:Point = new Point( _visibleWidth, _visibleHeight );

			topLeft = localToGlobal( topLeft );
			bottomRight = localToGlobal( bottomRight );

			// Conditions that discard a collision...
			if( stage.mouseX < topLeft.x ) return false;
			if( stage.mouseX > bottomRight.x ) return false;
			if( stage.mouseY < topLeft.y ) return false;
			if( stage.mouseY > bottomRight.y ) return false;

			return true;
		}

		// ---------------------------------------------------------------------
		// Updates.
		// ---------------------------------------------------------------------

		private function startEnterframe():void {
			if( !hasEventListener( Event.ENTER_FRAME ) ) {
				addEventListener( Event.ENTER_FRAME, enterframeHandler );
			}
			motionStartedSignal.dispatch();
			_active = true;
		}


		private function stopEnterframe():void {
			if( hasEventListener( Event.ENTER_FRAME ) ) {
				removeEventListener( Event.ENTER_FRAME, enterframeHandler );
			}
			motionEndedSignal.dispatch();
			_active = false;
		}

		private function enterframeHandler( event:Event ):void {
//			trace( this, ">>> updating scroller <<<" ); // This should trace only when there is motion in the scroller.
			_interactionManager.update();
			_positionManager.update();
			refreshToPosition();
			motionUpdatedSignal.dispatch();
			onUpdate();
		}

		// ---------------------------------------------------------------------
		// Events.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		private function onPositionManagerMotionEnded():void {
			stopEnterframe();
		}

		// ---------------------------------------------------------------------
		// Visualization utils.
		// ---------------------------------------------------------------------

		protected function visualizeVisibleDimensions():void {
			graphics.beginFill( 0xFF0000, 1.0 );
			graphics.drawRect( 0, 0, _visibleWidth, _visibleHeight );
			graphics.endFill();
		}

		protected function visualizeContentDimensions():void {
			_container.graphics.beginFill( 0x0000FF, 1.0 );
			_container.graphics.drawRect( 0, 0, contentWidth, 100 );
			_container.graphics.endFill();
		}

		protected function visualizeSnapPoints():void {
			var i:uint;
			var len:uint = _positionManager.numSnapPoints;
			for( i = 0; i < len; ++i ) {
				var px:Number = _positionManager.getSnapPointAtIndex( i );
				_container.graphics.beginFill( 0x00FF00 );
				_container.graphics.drawCircle( px, 0, 10 );
				_container.graphics.endFill();
			}
		}
	}
}
