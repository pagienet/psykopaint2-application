package net.psykosoft.psykopaint2.core.models
{
	import net.psykosoft.psykopaint2.core.signals.NotifyGalleryImagesFetchedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintingCommentAddedSignal;

	public class DummyGalleryService implements GalleryService
	{
		[Inject]
		public var notifyGalleryImagesFetchedSignal : NotifyGalleryImagesFetchedSignal;

		[Inject]
		public var notifyPaintingCommentAddedSignal : NotifyPaintingCommentAddedSignal;

		public function DummyGalleryService()
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

			var dummyTitles : Array = [
					"The Rise and Fall of Dr. Flabbybottoms",
					"Sausage Man with a Little Bit of a Hand",
					"North Malden",
					"A Scotsman on a Horse",
					"Burns Verkaufen der Kraftwerk",
					"You Only Move Twice",
					"My eyes! Ze goggles do nossink!",
					"Mr. Plow",
					"Whither Canada?",
					"Owl Stretching Time",
					"How to Recognize Different Parts of the Body",
					"Scott of the Antarctic",
					"Njorl's Saga",
					"Blood, Devastation, Death, War and Horror",
					"Mr. Neutron"
			];

			for (var i : int = 0; i < amount; ++i) {
				var item : DummyGalleryImageProxy = new DummyGalleryImageProxy();
				var userIndex : int = Math.random()*dummyNames.length;
				var titleIndex : int = Math.random()*dummyTitles.length;
				item.id = i;
				item.userName = dummyNames[userIndex];
				item.title = dummyTitles[titleIndex];
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

		public function addComment(paintingID : int, text : String) : void
		{
			notifyPaintingCommentAddedSignal.dispatch();
		}
	}
}
