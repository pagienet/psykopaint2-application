package net.psykosoft.psykopaint2.home.assets
{

	public class HomeEmbeddedAssets
	{
		[Embed(source="../../../../../../assets/embedded/away3d/paintings/settingsFrame.png")]
		public var SettingsPainting:Class;

		[Embed(source="../../../../../../assets/embedded/away3d/easel/easel-uncompressed.atf", mimeType="application/octet-stream")]
		public var EaselImage:Class;

		[Embed(source="../../../../../../assets/embedded/away3d/objects/settingsPanel.png")]
		public var SettingsPanel:Class;

		[Embed(source="../../../../../../assets/embedded/away3d/floorpapers/wood-ios-mips.atf", mimeType="application/octet-stream")]
		public var FloorPaperIos:Class;

		[Embed(source="../../../../../../assets/embedded/away3d/floorpapers/wood-desktop-mips.atf", mimeType="application/octet-stream")]
		public var FloorPaperDesktop:Class;

		// TODO: can we not embed both versions of platform specific files here?

		private static var _instance:HomeEmbeddedAssets;

		public function HomeEmbeddedAssets() {
			super();
		}

		public static function get instance():HomeEmbeddedAssets {
			if( !_instance ) _instance = new HomeEmbeddedAssets();
			return _instance;
		}
	}
}
