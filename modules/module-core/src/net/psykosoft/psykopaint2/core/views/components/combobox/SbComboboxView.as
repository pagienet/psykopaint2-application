package net.psykosoft.psykopaint2.core.views.components.combobox
{

    import com.greensock.TweenLite;
    import com.greensock.easing.Elastic;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

//	import net.psykosoft.psykopaint2.utils.decorator.DraggableDecorator;

    public class SbComboboxView extends Sprite {

        private var _listView:SbListView;
        private var _listViewContainer:Sprite;
//        private var _dragDecorator:DraggableDecorator; TODO: check what the drag decorator is for and activate if needed
        private var _selectedIndex:int;
        private var _opened:Boolean = false;

        public function SbComboboxView() {

                super();


                _listView = new SbListView();
                _listViewContainer = new Sprite();

                _listViewContainer.x=43;
                _listViewContainer.y=20;


                _listViewContainer.addChild(_listView);
                this.addChild(_listViewContainer);

//              _dragDecorator = new DraggableDecorator(_listView,new Rectangle(0,0,_listView.width,_listView.height));
                _listView.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownEvent );
                _listView.addEventListener( SbListView.CHANGE, onChangeList );

        }



        private function onChangeList(e:Event):void
        {
            dispatchEvent(new Event(Event.CHANGE));
        }

        private function onMouseDownEvent(e:MouseEvent):void
        {

            if( !_opened ){
            //var position:Point = touch.getLocation(_listView);   TODO: check if this line is needed, else remove it

            _listView.expand();
            TweenLite.to(_listView, _listView.tweenSpeed, { y:-_listView.selectedIndex*_listView.height/_listView.length, ease:Elastic.easeOut });

//          _dragDecorator.shiftPosition.y+=_listView.selectedIndex*_listView.height/_listView.length;
            _opened = true;
            }
            else{
          //SNAP VIEW TO CURRENT VIEW

            var positionIndex:int = getPositionIndex();
            TweenLite.to(_listView, _listView.tweenSpeed, { y:0, ease:Elastic.easeOut });
            _listView.collapse(positionIndex);
            _selectedIndex = positionIndex;

            _opened = false;
            }
        }





        private function getPositionIndex():int{

            var positionRatio:Number = -_listView .y / _listView.height;

            return Math.max(Math.min(Math.round(positionRatio*_listView.length),_listView.length-1),0);
        }

        public function addItem(params:Object):void
        {

            _listView.addItem(params);

            //UPDATE DRAG DECORATOR
    //            _dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height+10));
        }


        public function addItemAt(params:Object,index:int):void
        {

            _listView.addItemAt(params,index);

            //UPDATE DRAG DECORATOR
    //            _dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height+10));
        }


        public function removeItemAt(index:int):void
        {

            _listView.removeItemAt(index);

            //UPDATE DRAG DECORATOR
    //            _dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height+10));
        }

        public function removeAll():void
        {

            _listView.removeAll();

            //UPDATE DRAG DECORATOR
    //            _dragDecorator.setBounds(new Rectangle(0,-_listView.height,0,_listView.height+10));
        }

        public function get selectedIndex():int
        {
            return _selectedIndex;
        }

        public function set selectedIndex(value:int):void
        {
            _selectedIndex = value;

            TweenLite.to(_listView, _listView.tweenSpeed, { y:-1, height:1, ease:Elastic.easeOut });
            _listView.collapse(_selectedIndex);
        }


        public function get selectedItem():SbListItemVO
        {
            return _listView.selectedItem;
        }



    }
}
