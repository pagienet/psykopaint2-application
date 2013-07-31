package net.psykosoft.psykopaint2.core.managers.rendering
{
	public class GpuRenderManager
	{
		// TODO: confirm
		public static var _renderingSteps:Vector.<Function> = new Vector.<Function>(); // public because asc2 seems to have a problem here with private
		public static var _preRenderingSteps:Vector.<Function> = new Vector.<Function>();
		public static var _postRenderingSteps:Vector.<Function> = new Vector.<Function>();

		static public function addRenderingStep( step:Function, type:uint, index:int = -1 ):void {
			switch( type ) {
				case GpuRenderingStepType.NORMAL:
					addToCollection(step, index, _renderingSteps);
					break;
				case GpuRenderingStepType.PRE_CLEAR:
					addToCollection(step, index, _preRenderingSteps);
					break;
				case GpuRenderingStepType.POST_PRESENT:
					addToCollection(step, index, _postRenderingSteps);
					break;
			}
		}

		private static function addToCollection(step : Function, index : int, collection : Vector.<Function>) : void
		{
			if (index == -1) collection.push(step);
			else collection.splice(index, 0, step);
		}

		static public function removeRenderingStep( step:Function, type:uint ):void {
			switch( type ) {
				case GpuRenderingStepType.NORMAL:
					removeFromCollection(step, _renderingSteps);
					break;
				case GpuRenderingStepType.PRE_CLEAR:
					removeFromCollection(step, _preRenderingSteps);
					break;
				case GpuRenderingStepType.POST_PRESENT:
					removeFromCollection(step, _postRenderingSteps);
					break;
			}
		}

		private static function removeFromCollection(step : Function, collection : Vector.<Function>) : void
		{
			var index : int = collection.indexOf(step);
			if (index < 0)
				throw new Error("Removing a rendering step that was never added!");

			collection.splice(index, 1);
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
