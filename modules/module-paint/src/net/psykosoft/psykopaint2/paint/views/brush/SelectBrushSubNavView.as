package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.base.ui.components.ButtonGroup;
	import net.psykosoft.psykopaint2.core.views.components.button.SbButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SelectBrushSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Paint";
		public static const LBL_EDIT_BRUSH:String = "Edit Brush";

		private var _group:ButtonGroup;

		public function SelectBrushSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Pick a Brush" );
			navigation.setLeftButton( LBL_BACK );
			navigation.setRightButton( LBL_EDIT_BRUSH );
			navigation.layout();
		}

		public function setAvailableBrushes( availableBrushTypes:Vector.<String> ):void {
			var len:uint = availableBrushTypes.length;
			_group = new ButtonGroup();
			for( var i:uint; i < len; ++i ) {
				var btn:SbButton = navigation.createButton( availableBrushTypes[ i ] );
				_group.addButton( btn );
			}
			navigation.addCenterButtonGroup( _group );
			navigation.layout();
		}

		public function setSelectedBrush( activeBrushKit:String ):void {
			EditBrushCache.setLastSelectedBrush( activeBrushKit );
			_group.setSelectedButtonByLabel( activeBrushKit );
		}
	}
}
