package net.psykosoft.psykopaint2.core.views.components.combobox
{
    public class ListItemVO {

            public var label:String;
            public var odd:Boolean=false;

            private var _dataObject:Object;

        public function ListItemVO( dataObject:Object = null ) {

                this._dataObject = dataObject;
                if(dataObject){
                    label = dataObject['label'];
                    odd = (dataObject['odd'])?true:false;
                }

        }
    }
}