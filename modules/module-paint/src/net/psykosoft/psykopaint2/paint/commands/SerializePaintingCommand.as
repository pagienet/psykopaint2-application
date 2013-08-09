package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.data.PaintingDataSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoFactory;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoSerializer;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	import robotlegs.bender.bundles.mvcs.Command;

	public class SerializePaintingCommand extends Command
	{
		[Inject]
		public var saveVO:SavePaintingVO;

		[Inject]
		public var renderer:CanvasRenderer;

		override public function execute():void {

			trace( this + ", execute()" );

			var factory:PaintingInfoFactory = new PaintingInfoFactory();

			// TODO: This should become disposed after saving
			if( saveVO.info ) {
				trace( "disposing previous thumbnail" );
				saveVO.info.dispose();
			}

			saveVO.info = factory.createFromData( saveVO.data, saveVO.paintingId, saveVO.userId, generateThumbnail() );

			var infoSerializer:PaintingInfoSerializer = new PaintingInfoSerializer();
			var dataSerializer:PaintingDataSerializer = new PaintingDataSerializer();
			saveVO.infoBytes = infoSerializer.serialize( saveVO.info );
			saveVO.dataBytes = dataSerializer.serialize( saveVO.data );
			trace( this, "info num bytes: " + saveVO.infoBytes.length );
			trace( this, "data num bytes: " + saveVO.dataBytes.length );
		}

		private function generateThumbnail():BitmapData {
			// TODO: generate thumbnail by accepting scale in renderToBitmapData
			var thumbnail:BitmapData = renderer.renderToBitmapData();
			var scaledThumbnail:BitmapData = BitmapDataUtils.scaleBitmapData( thumbnail, 0.25 ); // TODO: apply different scales depending on source and target resolutions
			thumbnail.dispose();
			return scaledThumbnail;
		}
	}
}