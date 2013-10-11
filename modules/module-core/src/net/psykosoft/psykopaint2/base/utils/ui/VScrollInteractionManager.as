package net.psykosoft.psykopaint2.base.utils.ui
{

	import flash.display.Stage;

	import net.psykosoft.psykopaint2.base.utils.misc.StackUtil;

	/*
	* Changes a PositionManager's value with input from the stage.
	* Uses a StackUtil to soften input.
	* Needs to be told when to start/end interaction, doesn't do it by itself.
	* */
	public class VScrollInteractionManager
	{
		private var _stage:Stage;
		private var _isInteracting:Boolean;
		private var _positionManager:SnapPositionManager;
		private var _scrollInputMultiplier:Number = 1;
		private var _throwInputMultiplier:Number = 1;
		private var _pStack:StackUtil;

		public var useDetailedDelta:Boolean = true;

		public function VScrollInteractionManager( positionManager:SnapPositionManager ) {
			_positionManager = positionManager;
			_pStack = new StackUtil();
			_pStack.count = 6;
		}

		public function dispose():void {

			_positionManager = null;
			_stage = null;

			_pStack.dispose();
			_pStack = null;

		}

		public function set stage( value:Stage ):void {
			_stage = value;
		}

		public function startInteraction():void {
			if( _isInteracting ) return;
			_isInteracting = true;
			_pStack.clear();
			if( _stage ) _pStack.pushValue( -_stage.mouseY * _scrollInputMultiplier );
		}

		public function stopInteraction():void {
			if( !_isInteracting ) return;
			_isInteracting = false;
			var delta:Number = _throwInputMultiplier * ( useDetailedDelta ? _pStack.getAverageDeltaDetailed() : _pStack.getAverageDelta() );
			_positionManager.snap( -delta );
		}

		public function update():void {
			if( !_isInteracting || !_stage ) return;
			_pStack.pushValue( -_stage.mouseY * _scrollInputMultiplier );
			var delta:Number = useDetailedDelta ? _pStack.getAverageDeltaDetailed() : _pStack.getAverageDelta();
//			trace( this, "stack; " + _pStack.values() );
			_positionManager.moveFreelyByAmount( -delta );
		}

		public function get currentX():Number {
			if( !_stage ) return 0;
			return _stage.mouseX;
		}

		public function get currentY():Number {
			if( !_stage ) return 0;
			return _stage.mouseY;
		}

		public function set throwInputMultiplier( value:Number ):void {
			_throwInputMultiplier = value;
		}

		public function set scrollInputMultiplier( value:Number ):void {
			_scrollInputMultiplier = value;
		}

		public function get scrollInputMultiplier():Number {
			return _scrollInputMultiplier;
		}

		public function get pStack():StackUtil {
			return _pStack;
		}

		public function get isInteracting():Boolean {
			return _isInteracting;
		}
	}
}
