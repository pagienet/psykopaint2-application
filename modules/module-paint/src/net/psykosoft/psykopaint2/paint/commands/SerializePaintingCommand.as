package net.psykosoft.psykopaint2.paint.commands
{

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.core.data.PaintingDataSerializer;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoFactory;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoSerializer;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	import net.psykosoft.psykopaint2.paint.data.SavePaintingVO;

	import robotlegs.bender.bundles.mvcs.Command;

	public class SerializePaintingCommand extends Command
	{
		[Inject]
		public var saveVO:SavePaintingVO;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var requestUpdateMessagePopUpSignal:RequestUpdateMessagePopUpSignal;

		[Inject]
		public var stage:Stage;

		private var _time:uint;

		override public function execute():void {

			ConsoleView.instance.log( this, "execute()" );

			requestUpdateMessagePopUpSignal.dispatch( "Saving: Serializing...", "" );
			stage.addEventListener( Event.ENTER_FRAME, onOneFrame );
		}

		private function onOneFrame( event:Event ):void {
			stage.removeEventListener( Event.ENTER_FRAME, onOneFrame );
			serialize();
		}

		private function serialize():void {
			_time = getTimer();

			trace( this, "vo: " + saveVO );

			var factory:PaintingInfoFactory = new PaintingInfoFactory();

			if( saveVO.info ) {
				trace( "disposing previous thumbnail" );
				saveVO.info.dispose();
			}

			saveVO.info = factory.createFromData( saveVO.data, saveVO.paintingId, generateThumbnail() );
			saveVO.paintingId = saveVO.info.id;

			var infoSerializer:PaintingInfoSerializer = new PaintingInfoSerializer();
			var dataSerializer:PaintingDataSerializer = new PaintingDataSerializer();
			saveVO.infoBytes = infoSerializer.serialize( saveVO.info );
			saveVO.dataBytes = dataSerializer.serialize( saveVO.data );
			trace( this, "info num bytes: " + saveVO.infoBytes.length );
			trace( this, "data num bytes: " + saveVO.dataBytes.length );

			ConsoleView.instance.log( this, "done - " + String( getTimer() - _time ) );
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
