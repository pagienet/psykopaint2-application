package net.psykosoft.psykopaint2.core.views.components.combobox
{

    import flash.display.MovieClip;
    import flash.text.TextField;

    public class SbListItemView extends MovieClip {

		// Declared in Fla.
        public var tf:TextField;
		public var bg:MovieClip;

        private var _data:SbListItemVO;

        public function SbListItemView() {
            super();
			bg.stop();
        }

        public function setData(value:SbListItemVO):void {

            bg.gotoAndStop( value.odd ? 1 : 2 );

            if (value.label != tf.text) {
                tf.text = value.label;
				tf.selectable = false;
            }

            this._data = value;
        }

        public function getData():SbListItemVO {
            return _data;
        }

        /*
         override public function get height():Number{
         return _bgView.height
         }

         override public function set height(value:Number):void{
         _bgView.height = value;
         _txt.height = value;
         }*/

    }
}