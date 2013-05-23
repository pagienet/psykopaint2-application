package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.views.navigation.CrSubNavigationViewBase;

	public class PtSelectShapeSubNavView extends CrSubNavigationViewBase
	{
		public static const LBL_BACK:String = "Back";
		public static const LBL_EDIT:String = "Edit Brush";

		public function PtSelectShapeSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Pick a Shape" );

			areButtonsSelectable( true );

			setLeftButton( LBL_BACK );
			setRightButton( LBL_EDIT );

			invalidateContent();
		}

		public function setAvailableShapes( shapes:XML ):void {
			var types:XMLList = shapes[ 0 ].shape;
			var len:uint = types.length();
			for( var i:uint; i < len; ++i ) {
				trace( this, "type: " + types[ i ].@type );
				addCenterButton( types[ i ].@type );
			}
			invalidateContent();
		}
	}
}
