package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;
	import net.psykosoft.psykopaint2.base.utils.ScrollInteractionManager;
	import net.psykosoft.psykopaint2.base.utils.SnapPositionManager;

	import org.osflash.signals.Signal;

	public class HSnapScroller extends Sprite
	{
		protected var _interactionManager:ScrollInteractionManager;
		protected var _positionManager:SnapPositionManager;
		protected var _container:Sprite;
		protected var _active:Boolean;
		protected var _minContentX:Number = 0;
		protected var _maxContentX:Number = 0;

		public var edgeContentGap:Number = 0;

		public var visibleHeight:Number = 100;
		public var visibleWidth:Number = 600;

		// TODO: button presses conflict with scrolling
		// TODO: ability to change bg color and even not to use one ( avoid 0 alpha for gpu performance )

		public var motionStartedSignal:Signal;
		public var motionEndedSignal:Signal;

		public function HSnapScroller() {
			super();
			_positionManager = new SnapPositionManager();
			motionStartedSignal = new Signal();
			motionEndedSignal = new Signal();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function initialize():void {

			_container = new Sprite();
			super.addChild( _container );

			_container.cacheAsBitmap = true;
			// TODO: wouldn't it make more sense to only set cache as bitmap to true after all the childs have been added to the container?

			// TODO: confirm how usage of scroll rect affects performance in iPad
			/*
			* Last test with unstable stuff going on in stage3d shows that it is the
			* same to use scroll rect or not.
			* */
			// TODO: 1.5 hardcode allows vertical visibility to be isolated from the vertical interaction area. These should be properly isolated. Analyze performance impact too.
			// TODO: also, we could not only split them, but completely separate the area rects
 			scrollRect = new Rectangle( 0, 0, visibleWidth, visibleHeight * 1.5 );

			_interactionManager = new ScrollInteractionManager( stage, _positionManager );

			_positionManager.motionEndedSignal.add( onPositionManagerMotionEnded );
			_interactionManager.scrollInputMultiplier = 1 / ViewCore.globalScaling;
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function reset():void {
			_positionManager.reset();
			_container.x = 0;
			_minContentX = 0;
			_maxContentX = 0;
			_container.removeChildren();
		}

		override public function addChild( value:DisplayObject ):DisplayObject {
			_container.addChild( value );
			return value;
		}

		public function invalidateContent():void {
			// Add snap points.
			var len:uint = _container.numChildren;
			for( var i:uint; i < len; i++ ) {
				var child:DisplayObject = _container.getChildAt( i ) as DisplayObject;
				evaluateDimensionsFromChild( child );
				evaluateNewSnapPointFromPosition( child.x );
			}
			// Contain edges.
			containEdgeSnapPoints();
			// Dock at first snap point.
			if( _positionManager.numSnapPoints > 0 ) {
				_positionManager.snapAtIndex( 0 );
			}
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		protected function evaluateNewSnapPointFromPosition( px:Number ):void {
			// Override...
		}

		private function evaluateDimensionsFromChild( lastElement:DisplayObject ):void {
			var minX:Number = lastElement.x - lastElement.width / 2 - edgeContentGap; // Note: assumes elements will be registered at their center
			var maxX:Number = lastElement.x + lastElement.width / 2 + edgeContentGap;
			if( minX < _minContentX ) _minContentX = minX;
			if( maxX > _maxContentX ) _maxContentX = maxX;
		}

		private function containEdgeSnapPoints():void {
			// Sweep current snap points.
			var len:uint = _positionManager.numSnapPoints;
			var leftEdgeSnapPointMatched:Boolean = false;
			var rightEdgeSnapPointMatched:Boolean = false;
			var minAllowed:Number = visibleWidth / 2;
			var maxAllowed:Number = maxWidth - visibleWidth / 2;
			for( var i:uint; i < len; i++ ) {
				var snapPoint:Number = _positionManager.getSnapPointAt( i );
				// Left containment.
				if( snapPoint < minAllowed ) {
					if( leftEdgeSnapPointMatched ) {
						_positionManager.removeSnapPointAt( i );
						i--; len--;
						continue;
					}
					else {
						_positionManager.updateSnapPointAt( i, minAllowed );
						leftEdgeSnapPointMatched = true;
					}
				}
				// Right containment.
				if( snapPoint > maxAllowed ) {
					if( rightEdgeSnapPointMatched ) {
						_positionManager.removeSnapPointAt( i );
						i--; len--;
						continue;
					}
					else {
						_positionManager.updateSnapPointAt( i, maxAllowed );
						rightEdgeSnapPointMatched = true;
					}
				}
			}
		}

		private function mouseHitsPageArea():Boolean {

			var topLeft:Point = new Point( 0, 0 );
			var bottomRight:Point = new Point( visibleWidth, visibleHeight );

			topLeft = localToGlobal( topLeft );
			bottomRight = localToGlobal( bottomRight );

			// Conditions that discard a collision...
			if( stage.mouseX < topLeft.x ) return false;
			if( stage.mouseX > bottomRight.x ) return false;
			if( stage.mouseY < topLeft.y ) return false;
			if( stage.mouseY > bottomRight.y ) return false;

			return true;
		}

		public function evaluateInteractionStart():void {
			if( maxWidth - edgeContentGap <= visibleWidth ) return; // No need for scrolling if all content is visible in 1 page.
			if( !mouseHitsPageArea() ) return; // Hit test.
			_interactionManager.startInteraction();
			startEnterframe();
		}

		public function evaluateInteractionEnd():void {
			if( !_active ) return;
			_interactionManager.endInteraction();
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
			_container.x = visibleWidth / 2 - _positionManager.position;
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
		// Getters.
		// ---------------------------------------------------------------------

		override public function get height():Number {
			return visibleHeight;
		}

		override public function get width():Number {
			return _maxContentX - _minContentX;
		}

		public function get minWidth():Number {
			return Math.min( visibleWidth, width );
		}

		public function get maxWidth():Number {
			return Math.max( visibleWidth, width );
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
	}
}
