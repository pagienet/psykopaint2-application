package net.psykosoft.psykopaint2.view.starling.popups.base
{

	public class PopUpType
	{
		// Note: String content refers to the class name associated to the pop up.
		// Remember to make mention of the classes in IncludeClassesConfig.as for proper dynamic class instance referencing.
		public static const MESSAGE:String = "MessagePopUpView";
		public static const NO_FEATURE:String = "FeatureNotImplementedPopUpView";
		public static const NO_PLATFORM:String = "FeatureNotInPlatformPopUpView";
		public static const SETTINGS:String = "SettingsPopUpView"; // TODO: this is deprecated, there will be multiple sub settings pop ups, but not a central one
		public static const CAPTURE_IMAGE:String = "CaptureImagePopUpView";
		public static const CONFIRM_CAPTURE_IMAGE:String = "ConfirmCapturePopUpView";
	}
}
