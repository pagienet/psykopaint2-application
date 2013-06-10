package net.psykosoft.psykopaint2.core.views.components.combobox
{

    import flash.display.MovieClip;
    import flash.text.TextField;

    public class SbListItemView extends MovieClip {

        private var _txt:TextField;
        private var _data:SbListItemVO;

        public function SbListItemView() {

            super();

            _txt = new TextField();
            _txt.width = this.width;
            _txt.height = this.height;
            _txt.x = 30;
            _txt.y = 0; //TODO: set y offset for label without creating gaps between items
            this.addChild(_txt);
        }

        public function setData(value:SbListItemVO):void {

            gotoAndStop( value.odd ? 1 : 2 );

            if (value.label != _txt.text) {
                _txt.text = value.label;
				_txt.selectable = false;
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