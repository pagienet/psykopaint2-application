package net.psykosoft.psykopaint2.ui.theme.buttons
{

	import feathers.controls.Button;
	import feathers.skins.Scale3ImageStateValueSelector;
	import feathers.textures.Scale3Textures;

	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;

	public class LeftEdgeLabelButtonSkinManager extends ButtonsSkinManagerBase
	{
		private var _leftLabelSkinTextures:Scale3Textures;

		public function LeftEdgeLabelButtonSkinManager() {

			super();

			_textFormat.margin = 0;

			// Scale 9 bg texture for button labels.
			_leftLabelSkinTextures = new Scale3Textures( Psykopaint2Ui.instance.footerAtlas.getTexture( "leftLabel" ), 39, 89, Scale3Textures.DIRECTION_HORIZONTAL );

			// Initializers.
			Psykopaint2Ui.instance.setInitializerForClass( Button, labelButtonInitializer, ButtonSkinType.PAPER_LABEL_LEFT );
		}

		private function labelButtonInitializer( button:Button ):void {

			const skinSelector:Scale3ImageStateValueSelector = new Scale3ImageStateValueSelector();
			skinSelector.defaultValue = _leftLabelSkinTextures;

			button.stateToSkinFunction = skinSelector.updateValue;

			super.buttonInitializer( button );
		}
	}
}
