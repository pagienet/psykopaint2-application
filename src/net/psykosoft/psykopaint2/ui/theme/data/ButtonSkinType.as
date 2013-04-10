package net.psykosoft.psykopaint2.ui.theme.data
{

	import net.psykosoft.utils.MathUtil;

	public class ButtonSkinType
	{
		public static const PAPER_1:String = "paperButton1";
		public static const PAPER_2:String = "paperButton2";
		public static const PAPER_3:String = "paperButton3";
		public static const LABEL:String = "labelButton";
		public static const PAPER_LABEL_LEFT:String = "paperLabelLeftButton";
		public static const PAPER_LABEL_RIGHT:String = "paperLabelRightButton";

		public static function pickRandomPaperButtonName():String {

			var rand:int = MathUtil.randRnd( 0, 2 );
			switch( rand ) {
				case 0:
					return PAPER_1;
					break;
				case 1:
					return PAPER_2;
					break;
				case 2:
					return PAPER_3;
					break;
			}
			return PAPER_1;
		}
	}
}
