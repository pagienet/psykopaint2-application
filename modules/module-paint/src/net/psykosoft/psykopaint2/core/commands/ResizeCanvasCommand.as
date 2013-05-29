package net.psykosoft.psykopaint2.core.commands
{
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;

	public class ResizeCanvasCommand
	{
		[Inject]
		public var canvas:CanvasModel;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var textureSize:uint;

		public function execute():void {
			canvas.init(textureSize, textureSize);
			renderer.init();
		}
	}
}
