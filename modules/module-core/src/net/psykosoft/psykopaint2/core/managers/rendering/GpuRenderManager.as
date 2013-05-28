package net.psykosoft.psykopaint2.core.managers.rendering
{

	public class GpuRenderManager
	{
		private static var _renderingSteps:Vector.<Function> = new Vector.<Function>();
		private static var _preRenderingSteps:Vector.<Function> = new Vector.<Function>();
		private static var _postRenderingSteps:Vector.<Function> = new Vector.<Function>();

		static public function addRenderingStep( step:Function, type:uint ):void {
			switch( type ) {
				case GpuRenderingStepType.NORMAL: {
					_renderingSteps.push( step );
					break;
				}
				case GpuRenderingStepType.PRE_CLEAR: {
					_preRenderingSteps.push( step );
					break;
				}
				case GpuRenderingStepType.POST_PRESENT: {
					_postRenderingSteps.push( step );
					break;
				}
			}
		}

		// -----------------------
		// Getters.
		// -----------------------

		public static function get renderingSteps():Vector.<Function> {
			return _renderingSteps;
		}

		public static function get preRenderingSteps():Vector.<Function> {
			return _preRenderingSteps;
		}

		public static function get postRenderingSteps():Vector.<Function> {
			return _postRenderingSteps;
		}
	}
}
