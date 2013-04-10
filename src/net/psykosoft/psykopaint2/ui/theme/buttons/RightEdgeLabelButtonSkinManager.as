package net.psykosoft.psykopaint2.ui.theme.buttons
{

	import feathers.controls.Button;
	import feathers.skins.Scale3ImageStateValueSelector;
	import feathers.textures.Scale3Textures;

	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;

	public class RightEdgeLabelButtonSkinManager extends ButtonsSkinManagerBase
	{
		private var _rightLabelSkinTextures:Scale3Textures;

		public function RightEdgeLabelButtonSkinManager() {

			super();

			_textFormat.margin = 50;

			// Scale 9 bg texture for button labels.
			_rightLabelSkinTextures = new Scale3Textures( Psykopaint2Ui.instance.themeAtlas.getTexture( "rightLabel" ), 7, 20, Scale3Textures.DIRECTION_HORIZONTAL );

			// Initializers.
			Psykopaint2Ui.instance.setInitializerForClass( Button, labelButtonInitializer, ButtonSkinType.PAPER_LABEL_RIGHT );
		}

		private function labelButtonInitializer( button:Button ):void {

			const skinSelector:Scale3ImageStateValueSelector = new Scale3ImageStateValueSelector();
			skinSelector.defaultValue = _rightLabelSkinTextures;

			button.stateToSkinFunction = skinSelector.updateValue;

			super.buttonInitializer( button );
		}
	}
}
