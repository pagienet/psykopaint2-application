package net.psykosoft.psykopaint2.ui.theme.buttons
{

	import feathers.controls.Button;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.text.BitmapFontTextFormat;

	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;

	import starling.text.BitmapFont;
	import starling.textures.TextureSmoothing;

	public class ButtonsSkinManagerBase
	{
		protected var _textFormat:BitmapFontTextFormat;

		private var _bitmapFont:BitmapFont;

		protected static const TEXT_COLOR:uint = 0x666666;
		protected static const TEXT_SIZE:uint = 16;

		public function ButtonsSkinManagerBase() {
			_bitmapFont = new BitmapFont( Psykopaint2Ui.instance.themeAtlas.getTexture( "helveticaneue" ), Psykopaint2Ui.instance.fontDescriptor );
			_textFormat = new BitmapFontTextFormat( _bitmapFont, TEXT_SIZE, TEXT_COLOR );
		}

		protected function buttonInitializer( button:Button ):void {
			button.defaultLabelProperties.textFormat = _textFormat;
			button.labelFactory = labelFactory;
		}

		private function labelFactory():ITextRenderer {
			const renderer:BitmapFontTextRenderer = new BitmapFontTextRenderer();
			renderer.smoothing = TextureSmoothing.NONE;
			return renderer;
		}
	}
}
