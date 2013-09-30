package net.psykosoft.psykopaint2.core.commands
{
	import net.psykosoft.psykopaint2.core.models.GalleryService;

	public class LovePaintingCommand
	{
		[Inject]
		public var galleryService : GalleryService;

		[Inject]
		public var paintingID : int;

		public function execute() : void
		{
			galleryService.favorite(paintingID);
		}
	}
}
