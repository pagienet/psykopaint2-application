package net.psykosoft.psykopaint2.core.managers.rendering
{

	public class GpuRenderManager
	{
		// TODO: confirm
		public static var _renderingSteps:Vector.<Function>; // public because asc2 seems to have a problem here with private
		public static var _preRenderingSteps:Vector.<Function>;
		public static var _postRenderingSteps:Vector.<Function>;

		static public function addRenderingStep( step:Function, type:uint ):void {
			switch( type ) {
				case GpuRenderingStepType.NORMAL: {
					if( !_renderingSteps ) _renderingSteps = new Vector.<Function>();
					_renderingSteps.push( step );
					break;
				}
				case GpuRenderingStepType.PRE_CLEAR: {
					if( !_preRenderingSteps ) _preRenderingSteps = new Vector.<Function>();
					_preRenderingSteps.push( step );
					break;
				}
				case GpuRenderingStepType.POST_PRESENT: {
					if( !_postRenderingSteps ) _postRenderingSteps = new Vector.<Function>();
					_postRenderingSteps.push( step );
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
