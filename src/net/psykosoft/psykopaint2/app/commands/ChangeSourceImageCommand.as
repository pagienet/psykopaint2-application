package net.psykosoft.psykopaint2.app.commands
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;

	public class ChangeSourceImageCommand
	{
		[Inject]
		public var image:BitmapData;

		[Inject]
		public var moduleManager:ModuleManager;

		public function execute():void {
			moduleManager.setSourceImage( image );
		}
	}
}
