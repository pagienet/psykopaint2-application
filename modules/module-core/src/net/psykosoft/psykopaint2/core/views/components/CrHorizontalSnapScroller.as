package net.psykosoft.psykopaint2.core.views.components
{

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.ui.BsViewCore;

	import net.psykosoft.psykopaint2.base.utils.BsScrollInteractionManager;
	import net.psykosoft.psykopaint2.base.utils.BsSnapPositionManager;

	import org.osflash.signals.Signal;

	public class CrHorizontalSnapScroller extends Sprite
	{
		private var _interactionManager:BsScrollInteractionManager;
		private var _positionManager:BsSnapPositionManager;
		private var _container:Sprite;
		private var _active:Boolean;
		private var _minContentX:Number = 0;
		private var _maxContentX:Number = 0;

		public var pageHeight:Number = 100;
		public var pageWidth:Number = 600;

		// TODO: button presses conflict with scrolling
		// TODO: ability to change bg color and even not to use one ( avoid 0 alpha for gpu performance )

		public var motionStartedSignal:Signal;
		public var motionEndedSignal:Signal;

		public function CrHorizontalSnapScroller() {
			super();
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
			scrollRect = new Rectangle( 0, 0, pageWidth, pageHeight );

			_positionManager = new BsSnapPositionManager();
			_positionManager.motionEndedSignal.add( onPositionManagerMotionEnded );

			_interactionManager = new BsScrollInteractionManager( stage, _positionManager );
			_interactionManager.scrollInputMultiplier = 1 / BsViewCore.globalScaling;
		}

		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------

		public function reset():void {
			_positionManager.reset();
			_minContentX = 0;
			_maxContentX = 0;
			updateBg();
			_container.removeChildren();
		}

		override public function addChild( value:DisplayObject ):DisplayObject {
			_container.addChild( value );
			return value;
		}

		public function invalidateContent():void {
			var len:uint = _container.numChildren;
			for( var i:uint; i < len; i++ ) {
				var child:DisplayObject = _container.getChildAt( i ) as DisplayObject;
				evaluateDimensionsFromChild( child );
				evaluateNewSnapPointFromPosition( child.x );
			}
			evaluateLastSnapPointContainment();
			updateBg();
			if( _positionManager.numSnapPoints > 0 ) {
				_positionManager.snapAtIndex( 0 );
			}
		}

		// ---------------------------------------------------------------------
		// Utils.
		// ---------------------------------------------------------------------

		private function evaluateLastSnapPointContainment():void {
			if( _positionManager.numSnapPoints == 0 ) return;
			var lastSnapPointIndex:uint = _positionManager.numSnapPoints - 1;
			var lastSnapPoint:Number = _positionManager.getSnapPointAt( lastSnapPointIndex );
			var lastAllowedSnapPointPosition:Number = maxWidth - pageWidth / 2;
			if( lastSnapPoint > lastAllowedSnapPointPosition ) {
				lastSnapPoint = maxWidth - pageWidth / 2;
				_positionManager.updateSnapPointAt( lastSnapPointIndex, lastSnapPoint );
			}
		}

		private function evaluateNewSnapPointFromPosition( px:Number ):void {
			var ratio:Number = Math.floor( px / pageWidth );
            if( ratio >= _positionManager.numSnapPoints ){
				var snap:Number = ratio * pageWidth + pageWidth / 2;
			    _positionManager.addSnapPoint( snap );
            }
		}

		private function evaluateDimensionsFromChild( lastElement:DisplayObject ):void {
			var minX:Number = lastElement.x - lastElement.width / 2; // Note: assumes elements will be registered at their center
			var maxX:Number = lastElement.x + lastElement.width / 2;
			if( minX < _minContentX ) _minContentX = minX;
			if( maxX > _maxContentX ) _maxContentX = maxX;
		}

		private function updateBg():void {
			// TODO: consider not using a display object just for capture?
//			graphics.clear();
//			graphics.beginFill( 0x666666, 0.0 ); // TODO: ability to set color and alpha for bg?
//			graphics.drawRect( 0, 0, pageWidth, pageHeight );
//			graphics.endFill();
		}

		private function mouseHitsPageArea():Boolean {

			var topLeft:Point = new Point( 0, 0 );
			var bottomRight:Point = new Point( pageWidth, pageHeight );

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
			if( maxWidth <= pageWidth ) return; // No need for scrolling if all content is visible in 1 page.
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
//			trace( this, "updating" ); // This should trace only when there is motion in the scroller.
			_interactionManager.update();
			_positionManager.update();
			_container.x = pageWidth / 2 - _positionManager.position;
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
			return pageHeight;
		}

		override public function get width():Number {
			return _maxContentX - _minContentX;
		}

		public function get minWidth():Number {
			return Math.min( pageWidth, width );
		}

		public function get maxWidth():Number {
			return Math.max( pageWidth, width );
		}

		public function get container():Sprite {
			return _container;
		}

		public function get isActive():Boolean {
			return _active;
		}
	}
}
