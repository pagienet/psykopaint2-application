package net.psykosoft.psykopaint2.app.commands
{

	import com.junkbyte.console.Cc;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;

	/*
	* Notifies the drawing core that the source image has changed.
	* */
	public class ChangeSourceImageCommand
	{
		[Inject]
		public var image:BitmapData;

		[Inject]
		public var moduleManager:ModuleManager;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		public function execute():void {

			Cc.log( this );

			// Initialize core with image.
			moduleManager.setSourceImage( image );

		}
	}
}
