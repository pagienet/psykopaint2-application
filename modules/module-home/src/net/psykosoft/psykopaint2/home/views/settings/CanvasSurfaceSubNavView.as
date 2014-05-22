package net.psykosoft.psykopaint2.home.views.settings
{
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.PolaroidButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class CanvasSurfaceSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";
		/* Settings */
		public static const ID_CANVAS:String = "Canvas";
		public static const ID_WOOD:String = "Wood";

		public function CanvasSurfaceSubNavView()
		{
			super();
		}

		override protected function onEnabled():void
		{
			setHeader("");
			setLeftButton(ID_BACK, ID_BACK, ButtonIconType.BACK);
		}

		override protected function onSetup():void
		{
			super.onSetup();
			createCenterButton(ID_CANVAS, ID_CANVAS, null, PolaroidButton, null, true);
			createCenterButton(ID_WOOD, ID_WOOD, null, PolaroidButton, null, true);
			validateCenterButtons();
		}

		public function setSelectedButton(id : String) : void
		{
			selectButtonWithLabel(id);
		}
	}
}
