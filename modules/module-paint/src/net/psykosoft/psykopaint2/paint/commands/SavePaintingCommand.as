package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopBinarySaveUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;

	public class SavePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		[Inject]
		public var canvasModel:CanvasModel;

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Obtain full scale images that composite the painting.
			// TODO... using dummy images for now.
			var diffuseImage:BitmapData = new BitmapData( 1024, 768, false, 0xFF0000 ); diffuseImage.perlinNoise( 50, 50, 8, Math.floor( 1000 * Math.random() ), false, true, 7 );
			var heightmapImage:BitmapData = new BitmapData( 1024, 768, false, 0x00FF00 ); heightmapImage.perlinNoise( 5, 5, 8, Math.floor( 1000 * Math.random() ), true, true, 7 );
			var compositeImage:BitmapData = new BitmapData( 1024, 768, false, 0x0000FF ); compositeImage.perlinNoise( 250, 250, 8, Math.floor( 1000 * Math.random() ), false, true, 7 );

			// Produce data vo.
			var vo:PaintingVO = new PaintingVO();
			vo.diffuseImage = diffuseImage;
			vo.heightmapImage = heightmapImage;
			vo.compositeImage = compositeImage;
			vo.id = paintingId;

			// Serialize data.
			var voBytes:ByteArray = vo.serialize();

			// Deliver to binary writer.
			if( CoreSettings.RUNNING_ON_iPAD ) {
				// TODO...
			}
			else {
				DesktopBinarySaveUtil.saveToDesktop( voBytes, PaintSettings.desktopDataFolderName + "/painting-" + paintingId + PaintSettings.paintingFileExtension );
			}
		}
	}
}
