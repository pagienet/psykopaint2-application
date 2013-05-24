package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.robotlegs.TracingCommand;

	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;

	public class SetSourceImageCommand extends TracingCommand
	{
		[Inject]
		public var image:BitmapData;

		[Inject]
		public var moduleManager:ModuleManager;

		override public function execute():void {
			super.execute();
			moduleManager.setSourceImage( image );
		}
	}
}
