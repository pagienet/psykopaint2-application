package net.psykosoft.psykopaint2.paint.views.color
{

	import com.quasimondo.geom.ColorMatrix;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.ui.BsViewBase;

	public class PtColorStyleView extends BsViewBase
	{
		// TODO: commented by li, we don't use starling anymore
		/*private var _previewImage:Image;
		private var _texture:Texture;*/
		private var _previewMap:BitmapData;
		// TODO: commented by li, we don't use starling anymore
//		private var _cmf:ColorTransferFilter;

		public function PtColorStyleView() {
			super();
			// TODO: commented by li, we don't use starling anymore
//			_cmf = new ColorTransferFilter();
		}

		public function renderPreviewToBitmapData():void {
			// TODO: commented by li, we don't use starling anymore
			/*var support:RenderSupport = new RenderSupport();
			RenderSupport.clear();
			var nativeWidth:Number = Starling.current.viewPort.width
			var nativeHeight:Number = Starling.current.viewPort.height;

			support.setOrthographicProjection( 0, 0, nativeWidth, nativeHeight );
			support.applyBlendMode( false );
			support.pushMatrix();

			_cmf.render( _previewImage, support, 1.0 );
			//_previewImage.render(support, 1.0);
			support.popMatrix();

			support.finishQuadBatch();
			Starling.context.drawToBitmapData( _previewMap );*/
		}

		public function set previewMap( map:BitmapData ):void {
			// TODO: commented by li, we don't use starling anymore
			/*if( _texture ) _texture.dispose();
			_previewMap = map;
			_texture = Texture.fromBitmapData( _previewMap );

			if( !_previewImage ) {
				_previewImage = new Image( _texture );
				_previewImage.filter = _cmf;
				addChild( _previewImage );
			} else {
				_previewImage.texture = _texture;
			}*/
		}

		public function updateColorMatrices( matrix1:ColorMatrix, matrix2:ColorMatrix, threshold:Number, range:Number ):void {
			// TODO: commented by li, we don't use starling anymore
//			_cmf.updateSettings( matrix1, matrix2, threshold, range );
		}
	}
}
