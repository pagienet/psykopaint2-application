package net.psykosoft.psykopaint2.book.services
{
	import net.psykosoft.psykopaint2.book.model.DummyGalleryImageProxy;
	import net.psykosoft.psykopaint2.book.model.GalleryImageCollection;
	import net.psykosoft.psykopaint2.book.signals.NotifyGalleryImagesFetchedSignal;
	import net.psykosoft.psykopaint2.core.models.PaintMode;

	public class DummyGalleryImageService implements GalleryImageService
	{
		[Inject]
		public var notifyGalleryImagesFetchedSignal : NotifyGalleryImagesFetchedSignal;

		public function DummyGalleryImageService()
		{
		}

		public function fetchImages(source : int, index : int, amount : int) : void
		{
			var collection : GalleryImageCollection = new GalleryImageCollection();
			var dummyNames : Array = [
				"Mr. T", "Michael Jackson", "Charles de Batz-Castelmore d'Artagnan", "Madame de la Coeur Brisee",
				"Max Fightmaster", "Max Powers", "Butch Cassidy", "The Sundance Kid", "He-Man of Eternia", "Skeletor",
				"Don Corleone", "Il Palazzo", "Pedro", "Ikari Gendo", "Nabeshin", "Spike Spiegel", "Fritz Lang",
				"Freddy Mercury", "George Costanza", "Jay Intelli", "Chuck H. Norris", "Good ol' Chimney Trick",
				"Al Bundy", "Pensman", "Timmy Downdewell", "Nicolas Cage", "Shao Khan", "Bedrich Smetana",
				"Jimi Hendrix", "Jeremy Spoken", "Larry David", "Mario and RobotLegs' love child", "Garth Marenghi",
				"Rick Dagless", "Dean Learner", "Steve Pising", "Rick Deckard", "Benny Lava"
			];

			for (var i : int = 0; i < amount; ++i) {
				var item : DummyGalleryImageProxy = new DummyGalleryImageProxy();
				var userIndex : int = Math.random()*dummyNames.length;
				item.userName = dummyNames[userIndex];
				item.numComments = Math.random()*1000;
				item.numLikes = Math.random()*100000;
				item.paintingMode = Math.random() < .5? PaintMode.COLOR_MODE : PaintMode.PHOTO_MODE;
				collection.images.push(item);
			}

			collection.numTotalPaintings = 38;
			collection.type = source;
			collection.index = index;

			notifyGalleryImagesFetchedSignal.dispatch(collection);
		}
	}
}
