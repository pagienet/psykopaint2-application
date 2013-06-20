package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.base.robotlegs.commands.TracingCommand;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.DesktopBinarySaveUtil;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.paint.config.PaintSettings;
	import net.psykosoft.psykopaint2.paint.data.PaintingVO;

	public class SavePaintingCommand extends TracingCommand
	{
		[Inject]
		public var paintingId:String; // From signal.

		public function SavePaintingCommand() {
			super();
		}

		override public function execute():void {
			super.execute();

			// Obtain full scale images that composite the painting.
			// TODO... using dummy images for now.
			var diffuseImage:BitmapData = new BitmapData( 1024, 768, false, 0xFF0000 );
			var heightmapImage:BitmapData = new BitmapData( 1024, 768, false, 0x00FF00 );
			var compositeImage:BitmapData = new BitmapData( 1024, 768, false, 0x0000FF );

			// Produce thumbnails from images.
			var thumbScale:Number = 0.25;
			var diffuseThumb:BitmapData = BitmapDataUtils.scaleBitmap( diffuseImage, thumbScale );
			var heightmapThumb:BitmapData = BitmapDataUtils.scaleBitmap( heightmapImage, thumbScale );
			var compositeThumb:BitmapData = BitmapDataUtils.scaleBitmap( compositeImage, thumbScale );

			// Produce data vo.
			var vo:PaintingVO = new PaintingVO();
			vo.diffuseImage = diffuseImage;
			vo.heightmapImage = heightmapImage;
			vo.compositeImage = compositeImage;
			vo.diffuseThumb = diffuseThumb;
			vo.heightmapThumb = heightmapThumb;
			vo.compositeThumb = compositeThumb;
			vo.id = paintingId;

			// Serialize data.
			var voBytes:ByteArray = new ByteArray();
			voBytes.writeObject( vo );

			// Deliver to binary writer.
			if( CoreSettings.RUNNING_ON_iPAD ) {
				// TODO...
			}
			else DesktopBinarySaveUtil.saveToDesktop( voBytes, PaintSettings.saveDataFolderName + "/painting-" + paintingId );
		}
	}
}
