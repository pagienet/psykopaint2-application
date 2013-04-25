package net.psykosoft.psykopaint2.app.view.painting.colorstyle
{

	import com.quasimondo.geom.ColorMatrix;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.core.drawing.colortransfer.ColorTransferFilter;

	import starling.core.RenderSupport;
	import starling.core.Starling;

	import starling.display.Image;
	import starling.textures.Texture;

	public class ColorStyleView extends StarlingViewBase
	{
		private var _previewImage:Image;
		private var _texture:Texture;
		private var _previewMap:BitmapData;
		private var _cmf:ColorTransferFilter;

		public function ColorStyleView() {
			super();
			_cmf = new ColorTransferFilter();
		}

		override protected function onDispose():void {
			// TODO
		}

		/*protected function centerCanvas():void
		{
			if ( _previewImage )
			{
				_previewImage.x = 0.5 * ( stage.stageWidth - _previewImage.width );
				_previewImage.y = 0.5 * ( stage.stageHeight - _previewImage.height);
			}
		}*/

		public function renderPreviewToBitmapData():void
		{
			var support:RenderSupport = new RenderSupport();
			RenderSupport.clear();
			var nativeWidth:Number = Starling.current.viewPort.width;
			var nativeHeight:Number = Starling.current.viewPort.height;

			support.setOrthographicProjection(0,0,nativeWidth, nativeHeight);
			support.applyBlendMode(false);
			support.pushMatrix();

			_cmf.render(_previewImage,support, 1.0);
			//_previewImage.render(support, 1.0);
			support.popMatrix();

			support.finishQuadBatch();
			Starling.context.drawToBitmapData(_previewMap);

		}

		public function set previewMap( map:BitmapData ):void
		{
			if ( _texture ) _texture.dispose();
			_previewMap = map;
			_texture = Texture.fromBitmapData( _previewMap );

			if (!_previewImage ){
				_previewImage = new Image( _texture );
				_previewImage.filter = _cmf;
				addChild( _previewImage );
			} else {
				_previewImage.texture = _texture;
			}

		}

		public function updateColorMatrices(matrix1:ColorMatrix, matrix2:ColorMatrix, threshold:Number, range:Number):void {
			_cmf.updateSettings(matrix1,matrix2, threshold, range );
		}
	}
}
