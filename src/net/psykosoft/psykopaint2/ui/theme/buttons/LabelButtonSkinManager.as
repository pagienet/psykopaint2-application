package net.psykosoft.psykopaint2.ui.theme.buttons
{

	import feathers.controls.Button;
	import feathers.display.Scale3Image;
	import feathers.skins.Scale3ImageStateValueSelector;
	import feathers.textures.Scale3Textures;

	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;
	import net.psykosoft.utils.MathUtil;

	import starling.display.DisplayObject;
	import starling.filters.ColorMatrixFilter;

	/*
	* This skin represents the lower ( rectangle ) part of the main lower nav buttons that contain the text label.
	* It is combined with the upper part "PaperButtons" within CompoundButton.as
	* */
	public class LabelButtonSkinManager extends ButtonsSkinManagerBase
	{
		private var _paperButtonLabelSkinTextures:Scale3Textures;
		private var _selector:Scale3ImageStateValueSelector;

		public function LabelButtonSkinManager() {

			super();

			_textFormat.margin = 50;

			// Scale 9 bg texture for button labels.
			_paperButtonLabelSkinTextures = new Scale3Textures( Psykopaint2Ui.instance.footerAtlas.getTexture( "label" ), 16, 63, Scale3Textures.DIRECTION_HORIZONTAL );

			_selector = new Scale3ImageStateValueSelector();
			_selector.defaultValue = _paperButtonLabelSkinTextures;

			// Initializers.
			Psykopaint2Ui.instance.setInitializerForClass( Button, labelButtonInitializer, ButtonSkinType.LABEL );
		}

		private function labelButtonInitializer( button:Button ):void {
			button.stateToSkinFunction = buttonStateToSkinFunction;
			super.buttonInitializer( button );
		}

		private function buttonStateToSkinFunction( target:Button, state:Object, oldSkin:DisplayObject = null ):Object {

			var filter:ColorMatrixFilter = new ColorMatrixFilter();
			filter.adjustHue( MathUtil.rand( -1, 1 ) );
			filter.adjustSaturation( MathUtil.rand( -1, 1 ) );

			var scale3Image:Scale3Image = _selector.updateValue( target, state, oldSkin ) as Scale3Image;
			scale3Image.filter = filter;

			target.autoFlatten = true;

			return scale3Image;

		}
	}
}
