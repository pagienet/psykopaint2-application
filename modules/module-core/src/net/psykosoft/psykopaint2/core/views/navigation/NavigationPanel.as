package net.psykosoft.psykopaint2.core.views.navigation
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import net.psykosoft.psykopaint2.base.utils.ui.SnapPositionManager;
	import net.psykosoft.psykopaint2.base.utils.ui.VScrollInteractionManager;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	
	import org.osflash.signals.Signal;

	public class NavigationPanel extends Sprite
	{
		private var _shown:Boolean;
		private var _contentHeight:Number;
		private var _interactionManager:VScrollInteractionManager;
		private var _positionManager:SnapPositionManager;

		public var shownSignal:Signal;
		public var showingSignal:Signal;
		public var hidingSignal:Signal;
		public var hiddenSignal:Signal;
		public var positionChanged:Signal;

		public function NavigationPanel() {
			super();

			shownSignal = new Signal();
			hidingSignal = new Signal();
			showingSignal = new Signal();
			hiddenSignal = new Signal();
			positionChanged = new Signal();

			_positionManager = new SnapPositionManager();
			_positionManager.pushSnapPoint( 0 );
			_positionManager.pushSnapPoint( _contentHeight ); // Value gets overwritten when setting contentHeight()
			_positionManager.motionEndedSignal.add( onPositionManagerMotionEnded );
			_positionManager.frictionFactor = 0.8;
			_positionManager.minimumThrowingSpeed = 100;

			_interactionManager = new VScrollInteractionManager( _positionManager );
			_interactionManager.pStack.count = 2;
			_interactionManager.useDetailedDelta = false;
			_interactionManager.scrollInputMultiplier = 1 / CoreSettings.GLOBAL_SCALING;
			_interactionManager.throwInputMultiplier = 2;
			_interactionManager.useDetailedDelta = false;

			// Starts hidden.
			visible = false;
			contentHeight = 140;
			_positionManager.snapAtIndexWithoutEasing( 1 );

			// See comment on child management.
			y = 768 + _contentHeight;

			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			_interactionManager.stage = stage;
		}

		private function startEnterFrame():void {
			if( !hasEventListener( Event.ENTER_FRAME ) ) addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		private function refreshPosition():void {
			y = _positionManager.position + 768;
		}

		// ---------------------------------------------------------------------
		// Child management.
		// ---------------------------------------------------------------------

		override public function addChild( child:DisplayObject ):DisplayObject {

			// This view attaches to the bottom of the screen ( i.e. displays objects on negative Y ).
			// Incoming children are expected to come from views attached to the top of the screen ( i.e. objects placed on positive Y ).
			// Here we displace them to be compatible with this view.
			child.y -= 768;

			return super.addChild( child );
		}

		override public function addChildAt( child:DisplayObject, index:int ):DisplayObject {
			child.y -= 768;
			return super.addChildAt( child, index );
		}

		public function set contentHeight( value:Number ):void {

			_contentHeight = value;
			_positionManager.updateSnapPointAtIndex( 1, _contentHeight * 1.25 );

			// Uncomment to visualize the panel's active area.
//			this.graphics.clear();
//			this.graphics.beginFill( 0xFF0000, 0.5 );
//			this.graphics.drawRect( 0, -_contentHeight, 1024, _contentHeight );
//			this.graphics.endFill();
		}

		// ---------------------------------------------------------------------
		// Auto show/hide.
		// ---------------------------------------------------------------------

		public function toggle(skipTween:Boolean = false ):void {
			if( _shown ) hide(skipTween);
			else show(skipTween);
		}

		public function show( skipTween:Boolean = false ):void {
			trace( this, "show" );
			if( _shown ) return;
			visible = true;
			showingSignal.dispatch();
			
			TweenLite.killTweensOf( this );
			if ( !skipTween )
			{
				TweenLite.to( this, 0.2, {
					y:  _positionManager.getSnapPointAtIndex( 0 ) + 768,
					onComplete:function():void{_positionManager.position = y - 768;_shown = visible = true;shownSignal.dispatch();},
					ease: Strong.easeOut } );
			} else {
				y = _positionManager.getSnapPointAtIndex( 0 ) + 768;
				_positionManager.position = y - 768;
				_shown = visible = true;
		
				shownSignal.dispatch();
			}
			
		}

		public function hide( skipTween:Boolean = false  ):void {
			trace( this, "hide" );
			if( !_shown ) return;
			hidingSignal.dispatch();
			TweenLite.killTweensOf( this );
			if ( !skipTween )
			{
				
				TweenLite.to( this, 0.2, {
					y:  _positionManager.getSnapPointAtIndex( 1 ) + 768,
					onComplete:function():void{_positionManager.position = y - 768;_shown = visible = false;hiddenSignal.dispatch();},
					ease: Strong.easeOut } );
			} else {
				y = _positionManager.getSnapPointAtIndex( 1 ) + 768;
				_positionManager.position = y - 768;
				_shown = visible = false;
				
				hiddenSignal.dispatch();
				
			}
		}

		// ---------------------------------------------------------------------
		// Pan show/hide.
		// ---------------------------------------------------------------------

		public function startPanDrag( panY:Number ):void {

//			trace( this, "pan start: " + stage.mouseY );

			// Check if the pan started in the appropriate area.
			var closedTolerance:Number = 25;
			var minY:Number = shown ? 768 - _contentHeight : 768 - closedTolerance;
			minY *= CoreSettings.GLOBAL_SCALING;
			if( panY < minY ) return;

			// Start the panning.
			visible = true;
			_interactionManager.startInteraction();
			startEnterFrame();
		}

		public function endPanDrag():void {
			_interactionManager.stopInteraction();
		}

		// ---------------------------------------------------------------------
		// Event handlers.
		// ---------------------------------------------------------------------

		private function onEnterFrame( event:Event ):void {
			_interactionManager.update();
			_positionManager.update();
			refreshPosition();
		}

		private function onPositionManagerMotionEnded():void {

			// Remove enterframe.
			if( hasEventListener( Event.ENTER_FRAME ) ) removeEventListener( Event.ENTER_FRAME, onEnterFrame );

			// Evaluate shown and tied visible state.
			_shown = _positionManager.closestSnapPointIndex == 0;
			visible = _shown;

			// Notify.
			if( _shown ) shownSignal.dispatch();
			else hiddenSignal.dispatch();
			NavigationCache.isHidden = false;
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get shown():Boolean {
			return _shown;
		}

		override public function set y(value:Number):void
		{
			if (y != value) {
				super.y = value;
				positionChanged.dispatch(value - _positionManager.getSnapPointAtIndex( 1 ) - 768);
			}
		}
	}
}
