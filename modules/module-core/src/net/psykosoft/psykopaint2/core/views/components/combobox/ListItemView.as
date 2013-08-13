package net.psykosoft.psykopaint2.core.views.components.combobox
{

    import flash.display.MovieClip;
    import flash.text.TextField;

    public class ListItemView extends MovieClip {

		// Declared in Fla.
        public var tf:TextField;
		public var bg:MovieClip;

        private var _data:ListItemVO;

        public function ListItemView() {
            super();
			bg.stop();
        }

        public function setData(value:ListItemVO):void {

            bg.gotoAndStop( value.odd ? 1 : 2 );

            if (value.label != tf.text) {
                tf.text = value.label;
				tf.selectable = false;
            }

            this._data = value;
        }

        public function getData():ListItemVO {
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