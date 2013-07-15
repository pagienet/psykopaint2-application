package net.psykosoft.psykopaint2.core.managers.rendering
{

	public class GpuRenderManager
	{
		// TODO: confirm
		public static var _renderingSteps:Vector.<Function>; // public because asc2 seems to have a problem here with private
		public static var _preRenderingSteps:Vector.<Function>;
		public static var _postRenderingSteps:Vector.<Function>;

		static public function addRenderingStep( step:Function, type:uint, index:int = -1 ):void {
			switch( type ) {
				case GpuRenderingStepType.NORMAL: {
					if( !_renderingSteps ) _renderingSteps = new Vector.<Function>();
					if( index == -1 ) _renderingSteps.push( step );
					else _renderingSteps.splice( index, 0, step );
					break;
				}
				case GpuRenderingStepType.PRE_CLEAR: {
					if( !_preRenderingSteps ) _preRenderingSteps = new Vector.<Function>();
					if( index == -1 ) _preRenderingSteps.push( step );
					else _preRenderingSteps.splice( index, 0, step );
					break;
				}
				case GpuRenderingStepType.POST_PRESENT: {
					if( !_postRenderingSteps ) _postRenderingSteps = new Vector.<Function>();
					if( index == -1 ) _postRenderingSteps.push( step );
					else _postRenderingSteps.splice( index, 0, step );
					break;
				}
			}
		}

		// -----------------------
		// Getters.
		// -----------------------

		public static function get renderingSteps():Vector.<Function> {
			if( !_renderingSteps ) _renderingSteps = new Vector.<Function>();
			return _renderingSteps;
		}

		public static function get preRenderingSteps():Vector.<Function> {
			if( !_preRenderingSteps ) _preRenderingSteps = new Vector.<Function>();
			return _preRenderingSteps;
		}

		public static function get postRenderingSteps():Vector.<Function> {
			if( !_postRenderingSteps ) _postRenderingSteps = new Vector.<Function>();
			return _postRenderingSteps;
		}
	}
}
