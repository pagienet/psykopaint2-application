package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class SelectShapeSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Pick a Brush";
		public static const LBL_EDIT:String = "Edit Brush";

		public function SelectShapeSubNavView() {
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
				addCenterButton( types[ i ].@type );
			}
			invalidateContent();
		}

		public function setSelectedShape( activeBrushKitShape:String ):void {
			selectButtonWithLabel( activeBrushKitShape );
		}
	}
}
