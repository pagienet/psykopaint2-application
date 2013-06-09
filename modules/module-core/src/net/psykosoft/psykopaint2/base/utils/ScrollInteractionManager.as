package net.psykosoft.psykopaint2.base.utils
{

	import flash.display.Stage;

	/*
	* Changes a PositionManager's value with input from the stage.
	* Uses a StackUtil to soften input.
	* Needs to be told when to start/end interaction, doesn't do it by itself.
	* */
	public class ScrollInteractionManager
	{
		private var _stage:Stage;
		private var _isInteracting:Boolean;
		private var _positionManager:SnapPositionManager;
		private var _scrollInputMultiplier:Number = 1;
		private var _throwInputMultiplier:Number = 1;
		private var _pStack:StackUtil;

		public function ScrollInteractionManager( positionManager:SnapPositionManager ) {
			_positionManager = positionManager;
			_pStack = new StackUtil();
			_pStack.count = 6;
		}

		public function set stage( value:Stage ):void {
			_stage = value;
		}

		public function startInteraction():void {
			if( _isInteracting ) return;
			_isInteracting = true;
			_pStack.clear();
			if( _stage ) _pStack.pushValue( _stage.mouseX * _scrollInputMultiplier );
		}

		public function endInteraction():void {
			if( !_isInteracting ) return;
			_isInteracting = false;
			var delta:Number = _throwInputMultiplier * _pStack.getAverageDeltaDetailed();
			_positionManager.snap( -delta );
		}

		public function update():void {
			if( !_isInteracting || !_stage ) return;
			_pStack.pushValue( _stage.mouseX * _scrollInputMultiplier );
			var delta:Number = _pStack.getAverageDeltaDetailed();
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
	}
}
