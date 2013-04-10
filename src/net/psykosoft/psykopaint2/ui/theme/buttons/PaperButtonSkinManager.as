package net.psykosoft.psykopaint2.ui.theme.buttons
{

	import feathers.controls.Button;

	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.ui.extensions.selectors.ScaleImageStateValueSelector;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;

	import starling.textures.Texture;

	/*
	* This skin represents the upper ( square ) part of the main nav buttons that contain an icon and no text label.
	* It is combined with the lower part "LabelButtons" within CompoundButton.as
	* */
	public class PaperButtonSkinManager extends ButtonsSkinManagerBase
	{
		private var _paperButtonUpSkinTexture1:Texture;
		private var _paperButtonUpSkinTexture2:Texture;
		private var _paperButtonUpSkinTexture3:Texture;

		private var _textureBelongingToButtonType:Dictionary;

		public function PaperButtonSkinManager() {

			super();

			// Button bg textures.
			_paperButtonUpSkinTexture1 = Psykopaint2Ui.instance.themeAtlas.getTexture( "paper 1"  );
			_paperButtonUpSkinTexture2 = Psykopaint2Ui.instance.themeAtlas.getTexture( "paper 2"  );
			_paperButtonUpSkinTexture3 = Psykopaint2Ui.instance.themeAtlas.getTexture( "paper 3"  );

			// Associate button textures with their type.
			_textureBelongingToButtonType = new Dictionary();
			_textureBelongingToButtonType[ ButtonSkinType.PAPER_1 ] = _paperButtonUpSkinTexture1;
			_textureBelongingToButtonType[ ButtonSkinType.PAPER_2 ] = _paperButtonUpSkinTexture2;
			_textureBelongingToButtonType[ ButtonSkinType.PAPER_3 ] = _paperButtonUpSkinTexture3;

			// Initializers.
			Psykopaint2Ui.instance.setInitializerForClass( Button, paperButtonInitializer1, ButtonSkinType.PAPER_1 );
			Psykopaint2Ui.instance.setInitializerForClass( Button, paperButtonInitializer2, ButtonSkinType.PAPER_2 );
			Psykopaint2Ui.instance.setInitializerForClass( Button, paperButtonInitializer3, ButtonSkinType.PAPER_3 );
		}

		private function paperButtonInitializer( button:Button, type:String ):void {

			var texture:Texture = _textureBelongingToButtonType[ type ];

			const skinSelector:ScaleImageStateValueSelector = new ScaleImageStateValueSelector();
			skinSelector.defaultValue = texture;
//			skinSelector.setValueForState( texture, Button.STATE_DOWN );
//			skinSelector.setValueForState( texture, Button.STATE_HOVER );
//			skinSelector.setValueForState( texture, Button.STATE_UP );

			button.stateToSkinFunction = skinSelector.updateValue;

			super.buttonInitializer( button );
		}

		private function paperButtonInitializer1( button:Button ):void {
			paperButtonInitializer( button, ButtonSkinType.PAPER_1 );
		}

		private function paperButtonInitializer2( button:Button ):void {
			paperButtonInitializer( button, ButtonSkinType.PAPER_2 );
		}

		private function paperButtonInitializer3( button:Button ):void {
			paperButtonInitializer( button, ButtonSkinType.PAPER_3 );
		}
	}
}
