package net.psykosoft.psykopaint2.core.io
{
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;
	import net.psykosoft.psykopaint2.core.data.PaintingDataVO;
	import net.psykosoft.psykopaint2.core.managers.misc.IOAneManager;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTextureChannels;
	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	import net.psykosoft.psykopaint2.paint.utils.CopyColorAndSourceToBitmapDataUtil;
	import net.psykosoft.psykopaint2.paint.utils.CopyColorToBitmapDataUtil;

	/**
	 * Returns a list of 3 ByteArrays containing data:
	 * 0: painted color layer, in BGRA
	 * 1: normal/specular layer, in BGRA
	 * 2: the source texture, in RGBA!!! (because it's always used primarily as BitmapData)
	 */
	public class CanvasPublisher extends EventDispatcher
	{
		private static var _copySubTextureChannelsRGB : CopySubTextureChannels;
		private static var _copySubTextureChannelsA : CopySubTextureChannels;
		private static var _copyColorToBitmapData : CopyColorToBitmapDataUtil;
		private static var _copyColorAndSourceToBitmapData:CopyColorAndSourceToBitmapDataUtil;

		private var _canvas : CanvasModel;
		private var _paintingData : PaintingDataVO;
		private var _exportingStage : int;
		private var _workerBitmapData : BitmapData;
		private var _context3D : Context3D;
		private var _sourceRect : Rectangle;
		private var _destRect : Rectangle;
		private var _stage:Stage;
		private var _ioAne:IOAneManager;

		private var _exportingStages : Array;
		private var _jpegQuality : Number;
		private var _sourceThumbWidth : Number;

		public function CanvasPublisher( stage:Stage, ioAne:IOAneManager )
		{
			_stage = stage;
			_ioAne = ioAne;

			_copySubTextureChannelsRGB ||= new CopySubTextureChannels("xyz", "xyz");
			_copySubTextureChannelsA ||= new CopySubTextureChannels("w", "z");
			_copyColorToBitmapData ||= new CopyColorToBitmapDataUtil();
			_copyColorAndSourceToBitmapData ||= new CopyColorAndSourceToBitmapDataUtil();
		}

		// in this case, color will contain JPEG data, sourceImage will contain PNG Thumbnail, and normal data will be compressed with zlib
		public function exportForPublish(canvas : CanvasModel, paintSettings : UserPaintSettingsModel, jpegQuality : Number = 80, sourceThumbWidth : Number = 200) : void
		{
			_sourceThumbWidth = sourceThumbWidth;
			_jpegQuality = jpegQuality;
			_exportingStages = [
				saveColorFlat,
				saveNormalsFlat
			];

			if (paintSettings.hasSourceImage)
				_exportingStages.push(saveSourceDataToThumb);

			doExport(canvas);
		}

		private function doExport(canvas : CanvasModel) : void
		{
			if (_canvas) throw "Export already in progress!";
			_canvas = canvas;

			init();

			_exportingStage = 0;
			executeStage();
		}

		private function init() : void
		{
			_context3D = _canvas.stage3D.context3D;

			// TODO: No need to rectangles, can just copy textures
			_sourceRect = new Rectangle(0, 0, 1, 1);
			_destRect = new Rectangle(0, 0, 1, 1);

			_paintingData = new PaintingDataVO();

			_workerBitmapData = new TrackedBitmapData(_canvas.width, _canvas.height, false);

			_paintingData.width = _canvas.width;
			_paintingData.height = _canvas.height;

			_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event : Event) : void
		{
			_exportingStage++;
//			ConsoleView.instance.log( this, "onEnterFrame - stage: " + _exportingStage + "/" + _exportingStages.length );
			if ( _exportingStage < _exportingStages.length )
				executeStage();
			else
				onComplete();
		}

		private function executeStage() : void
		{
			_exportingStages[_exportingStage]();
			dispatchEvent(new CanvasPublishEvent(CanvasPublishEvent.PROGRESS, _paintingData, _exportingStage, _exportingStages.length));
		}

		private function saveColorFlat() : void
		{
			if (_canvas.sourceTexture)
				_copyColorAndSourceToBitmapData.execute(_canvas, _workerBitmapData);
			else
				_copyColorToBitmapData.execute(_canvas, _workerBitmapData);

			_paintingData.colorData = _workerBitmapData.encode(_workerBitmapData.rect, new JPEGEncoderOptions(_jpegQuality));
		}

		private function saveNormalsFlat() : void
		{
			_context3D.setRenderToBackBuffer();
			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_context3D.clear(0, 0, 0, 1);
			CopyTexture.copy(_canvas.normalSpecularMap, _context3D);
			_context3D.drawToBitmapData(_workerBitmapData);
			_paintingData.normalSpecularData = _workerBitmapData.encode(_workerBitmapData.rect, new JPEGXREncoderOptions(5,"auto",1));
		}

		private function saveSourceDataToThumb() : void
		{
			var context3D : Context3D = _canvas.stage3D.context3D;

			context3D.setRenderToBackBuffer();
			context3D.clear(0, 0, 0, 0);
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			CopySubTexture.copy(_canvas.sourceTexture, _sourceRect, _destRect, context3D);
			context3D.drawToBitmapData(_workerBitmapData);
			var scaledBitmapData : BitmapData = new TrackedBitmapData(_sourceThumbWidth, _sourceThumbWidth/_canvas.width*_canvas.height);
			scaledBitmapData.drawWithQuality(_workerBitmapData, new Matrix(_sourceThumbWidth/_canvas.width, 0, 0, _sourceThumbWidth/_canvas.width), null, null, null, true, StageQuality.BEST);
			_paintingData.sourceImageData =  scaledBitmapData.encode(scaledBitmapData.rect, new PNGEncoderOptions());
			scaledBitmapData.dispose();
		}

		private function onComplete() : void
		{
			_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_stage = null;
			_canvas = null;
			_context3D = null;
			_sourceRect = null;
			_destRect = null;
			_ioAne = null;
			_workerBitmapData.dispose();
			_workerBitmapData = null;

			dispatchEvent(new CanvasPublishEvent(CanvasPublishEvent.COMPLETE, _paintingData));
		}
	}
}
