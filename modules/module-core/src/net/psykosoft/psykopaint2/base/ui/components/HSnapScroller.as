package net.psykosoft.psykopaint2.base.ui.components
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.base.utils.ui.ScrollInteractionManager;
	import net.psykosoft.psykopaint2.base.utils.ui.SnapPositionManager;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;

	import org.osflash.signals.Signal;

	/*
	* Adds elements to a container which can be scrolled horizontally.
	* */
	public class HSnapScroller extends Sprite
	{
		protected var _interactionManager:ScrollInteractionManager;
		protected var _positionManager:SnapPositionManager;
		protected var _container:Sprite;
		protected var _active:Boolean;
		protected var _minContentX:Number = 0;
		protected var _maxContentX:Number = 0;

		public var leftGap:Number = 0;
		public var rightGap:Number = 0;
		public var scrollable:Boolean = true;

		public var visibleHeight:Number = 100;
		public var visibleWidth:Number = 600;

		public var motionStartedSignal:Signal;
		public var motionEndedSignal:Signal;

		public function HSnapScroller() {
			super();

			_positionManager = new SnapPositionManager();
			_interactionManager = new ScrollInteractionManager( _positionManager );
			_interactionManager.useDetailedDelta = false;

			motionStartedSignal = new Signal();
			motionEndedSignal = new Signal();

			_container = new Sprite();
			_container.cacheAsBitmap = true; // TODO: wouldn't it make more sense to only set cache as bitmap to true after all the children have been added to the container?
			super.addChild( _container );

			reset();

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
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
			_positionManager.reset();
			_minContentX = 0;
			_maxContentX = 0;
			_container.x = 0;
			_container.removeChildren();
		}

		public function dock():void {
			if( width < visibleWidth ) return;
			_positionManager.snapAtIndexWithoutEasing( 0 );
			refreshToPosition();
		}

		public function refreshToPosition():void {
			_container.x = visibleWidth / 2 - _positionManager.position;
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
				_positionManager.snapAtIndexWithoutEasing( 0 );
			}
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		protected function evaluateNewSnapPointFromPosition( px:Number ):void {
			// Override...
		}

		protected function evaluateDimensionsFromChild( lastElement:DisplayObject, offset:Number = 0 ):void {
			var minX:Number = offset + lastElement.x - lastElement.width / 2; // Note: assumes elements will be registered at their center
			var maxX:Number = offset + lastElement.x + lastElement.width / 2;
			trace( this, "evaluating dimensions - this - min: " + minX + ", max: " + maxX );
			if( minX < _minContentX ) _minContentX = minX;
			if( maxX > _maxContentX ) _maxContentX = maxX;
			trace( this, "evaluating dimensions - all - min: " + _minContentX + ", max: " + _maxContentX );
		}

		protected function containEdgeSnapPoints():void {
			// Sweep current snap points.
			var len:uint = _positionManager.numSnapPoints;
			var leftEdgeSnapPointMatched:Boolean = false;
			var rightEdgeSnapPointMatched:Boolean = false;
			var minAllowed:Number = visibleWidth / 2 - leftGap;
			var maxAllowed:Number = maxWidth + rightGap - visibleWidth / 2;
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

		private function mouseHitsInteractiveArea():Boolean {

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
			if( !scrollable ) return; // No need for scrolling if all content is visible in 1 page.
//			if( maxWidth <= visibleWidth ) return; // No need for scrolling if all content is visible in 1 page.
			if( !mouseHitsInteractiveArea() ) return; // Hit test.
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
			refreshToPosition();
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

		public function get interactionManager():ScrollInteractionManager {
			return _interactionManager;
		}
	}
}
