
/**
 * [Credits.hx]
 * State used for crediting all of the contributors to the mod with custom art
 * Also provides links 
*/
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
import funkin.backend.PlayerSettings;
import funkin.states.MainMenuState;
import funkin.scripting.PluginsManager;
import funkin.api.DiscordClient;

import mobile.controls.MobileDPadMode;
import mobile.controls.MobileActionMode;

var controls = PlayerSettings.player1.controls;

// Typedef made to simplify and improve the readability of a user's credit data
typedef CredData = {
	icon:String, // icon file name
	user:String, // username displayed
	desc:String, // quote
	creds:Array<String>, // array of the user's contributions
	links:Array<String>, // array of the user's linked social medias
	depth:Float, // if a message is too long, how far to scroll down
	height:Float, // if a message is too long, how tall it is
	time:Float // if a message is too long, how long until it starts scrolling down
}

// Array holding all the users
var credits:Array<CredData> = [
	{
		icon: "deacon",
		user: "DastardlyDeacon",
		creds: ['Director', 'Concept Artist', 'Character Designer'],
		desc: "Four years ago, on one fateful May in 2021, I was on my way home whilst being high as hell on some medicine I can't recall the name of after a doctor's visit. Right as we pull out, I have the barely-conscious thought of \"If I were to make my own FNF remix mod, the characters would all have different designs instead of just being recolours.\" During that ride home, I made the first sketch of D-Sides Boyfriend, with scruffy hair and a warning sign on the shirt. After talking about the concept for a bit, someone by the name of PhilipLol offered to make music and code for it. Once the mod was actually becoming real, I asked my friend Fifleo if he'd be down to make sprites for it sometime. Then, another friend of mine, gc, asked if he could compose some songs for Pico.\n\nThat's how it all started. 3 kids (and gc), working together to make a fun little mod that wasn't meant to be played by anyone outside of their respective friend groups. Never could any of us imagine that it would turn into the phenomenon that D-Sides is today, let alone us having...actual fanbases. It's so surreal to live in. D-Sides has gotten so large to the point where my sister recently became friends with someone and found out that her child likes FNF and has played D-Sides. Do you know how insane that was for me? That may be the moment where I realized what people meant when they say \"it's a small world\", as fuckin' corny as that is to say.\n\nIn these 4 years, I have met some of the kindest people. It would genuinely take too long to list everyone, but just about everyone you'll find in the credits here are just some of the fantastic people I've met. Despite all the shit that goes on in this community, I even love my fans. Yes, even you, player. I love you. Unless you're a child, then I think you're cool.  The FNF community has done so much more for me than most people would think. You guys have helped pay for an expensive surgery I desperately needed. The amount of times you guys have indirectly fed me and my family is...too many to count. And I appreciate that. Deeply. I'll never be able to repay what all of you have done for me, and the many, many other people on this mod that have gained their own opportunities in life thanks to D-Sides and all of you.\n\nThank you for everything. I hope you all enjoyed D-Sides 1.0 Redux. And I can promise that there are many more updates to come.",
		links: [
			'https://twitter.com/dastardlydeacon',
			'https://dastardlydeacon.newgrounds.com/',
			'https://bsky.app/profile/dastardlydeacon.bsky.social'
		],
		time: 5,
		depth: 2250,
		height: 2500
	},
	{
		icon: "leo",
		user: "FifLeo",
		creds: [
			'Lead Artist / Animator (Legacy & Redux)',
			'Character Designer',
			'Concept Artist'
		],
		desc: "THANK YOU! GOOD BYE!!",
		links: [
			'https://youtube.com/@fif_leo?si=K5ssto3-eQaijTWj',
			'https://twitter.com/fif_leo',
			'https://fifleo.newgrounds.com/'
		]
	},
	{
		icon: "ellis",
		user: "EllisBros",
		creds: [
			'Lead Redux Style Artist',
			'BG Artist (Legacy & Redux)',
			'Menu Artist',
			'Gallery Key Artist (Legacy & Redux)',
			'Character Designer',
			'Voice Contributions'
		],
		desc: "Watch out for the dsides tickle monster",
		links: ['https://twitter.com/EllisBros', 'https://ellisbros.newgrounds.com/']
	},
	{
		icon: "duskie",
		user: "DuskieWhy",
		creds: ['Lead Programmer', 'Lead Developer of Nightmare Vision', 'Charter', 'Promotional Video Editor', 'Sexy Beast'],
		desc: "I have been on FNF: D-Sides since early 2022, being added as the sole programmer since their (at the time) main programmer had left to persue other asperations. I was very nervous at first, D-Sides was a highly acclaimed mod at the time and I didn't wanna mess up infront of these people that I looked up to. Little did I know, working on D-Sides would introduce me to / further develop relationships with some of the greatest friends I have to this day. I am forever greatful that I had the opportunity to meet people like DastardlyDeacon, EllisBros, FifLeo, Kloogybaboogy, squishyzumorizu, and others. You are some of the kindest, most taleneted people I know and being able to work on a project that means this much to me would not be the same without y'all. Thank you for not immediately hating little 15-year-old me, LOL.\n\nD-Sides is by far the most proud I have ever been of my own work. Every single menu & transition was coded by me and me alone. I also programmed songs like South, Monster,  Improbable Outset, Boom Bash, Foolhardy, Try Harder, Endless, Milk, AND, dguy, Lore, Performance, Execution, and literally every OG song (note: i didn't solo code some of these, and i'm also probably forgetting some.. death to useraqua). I will absolutely be putting some of my work on my professional portfolio, I'm proud of everything I've put into this mod and I am beyond excited to continue to work with these lovely people.\n\nEvery single bit of programming in this mod has been implemented via soft-coding in my own personal psych engine fork entitled NightmareVision that I have been developing over the past few years alongside Data5. Working on this mod in my own framework has led to insane developments in said engine and I am absolutely astonished with the strides made. But I can't talk about how proud I am of the engine or mod without thanking Data. You have done some INSANE work on NMV and I am so unbelievably thankful, you're a huge help and I hope you know how much I appreciate you bro. Six seven\n\nStay creative man,  and never give up on your passion because of others. The FNF community can get bad sometimes, there's no denying that, but that will never stop be from being passionate about the game that changed my life and lead to me developing and expanding upon my talents. Stay cool, stay creative, and stay funky.\n\n- Cam Campbell, 11.18.25",
		depth: 2350,
		height: 3000,
		time: 5,
		links: [
			'https://youtube.com/@duskiewhy',
			'https://twitter.com/duskiewhy',
			'https://www.youtube.com/watch?v=m4SF6jzrrI4'
		]
	},
	{
		icon: "aqua",
		user: "theuseraqua",
		creds: ['Programmer', 'Blue Woke'],
		desc: "i hung out with squish one time and he bought me mcdonalds chicken mcnuggets",
		links: ['https://www.youtube.com/@theuseraqua', 'https://twitter.com/theuseraqua',]
	},
	{
		icon: "marco",
		user: "Marco Antonio",
		creds: ['Concept / Sprite Artist & Animator', 'Character Designer', 'Coder', 'Composer of Execution', 'Vocalist of Execution'],
		desc: "Es confuso verdad? Sin embargo skibidi mewing sigma está mal, todo el globo de texto te lo hace saber, te notas chad con pensamientos de decadencia, esa sensación de compa soy un buen compa  de que ya el prime no volverá a ser como antes. Yaya mijo ya venga la alegría npc un video ma mi gente insano heroico bobicraft descuido chamba goku god ojolero wachi wachi waa tito calderón oh me está comiendo buscar, ahora podría decirse fuiste un insano sin saberlo. \n\n Hola faro te mando un beso muah",
		depth: 430,
		time: 2,
		links: ['https://www.youtube.com/@MarcoAntonioOffic', 'https://twitter.com/MarcoJurez19']
	},
	{
		icon: "squish",
		user: "squishyzumorizu",
		creds: [
			'Composer of Darnell',
			'Composer of Boombash',
			'Composer of Game Over (Pico Mix)',
			'Composer of Talkin Smack',
			'Composer and Vocalist of Stay Funky',
			'Composer of Milk',
			'Live Instrumentation (Guitar)',
			'Sound Designer',
			'Concept / Sprite Artist & Animator',
			'Character Designer',
			'Branding',
			'Charter'
		],
		desc: "For the longest time, I've taken the backseat in developing this mod. From here on out, I will be contributing to this project I hold so close to my heart more than ever! A smile's enough.",
		links: [
			'https://www.youtube.com/@Squish_26',
			'https://twitter.com/Squish_26',
			'https://bsky.app/profile/squish26.bsky.social'
		],
		depth: 320,
		time: 2
	},
	{
		icon: "yoisabo",
		user: "yoisabo",
		creds: ['Menu/UI Artist'],
		desc: "truth checked!",
		links: ['https://twitter.com/ayoisabo']
	},
	{
		icon: "tgg",
		user: "TGG (That Goofy Guy)",
		creds: [
			'Freeplay Icon Artist',
			'Performance Spritework (Redux)',
			'Lore Phone Call Cutscene (Redux)',
			'Character Designer'
		],
		desc: "I'm a shill",
		links: [
			'https://www.youtube.com/@thatgoofyguy6980',
			'https://twitter.com/TGGtheStickBoy',
			'https://bsky.app/profile/thatgoofyguy.bsky.social'
		]
	},
	{
		icon: "dieg",
		user: "Dieg",
		creds: ['Sprite Artist & Animator', 'Concept Artist', 'Character Designer'],
		desc: ":homer:"
	},
	{
		icon: "steve",
		user: "Stonesteve",
		creds: ['Sprite Artist & Animator'],
		desc: "You Could Never Make Me Hate You Friday Night Funkin': Vs Grimace Shake.",
		links: ['https://twitter.com/stonesteve_']
	},
	{
		icon: "offbi",
		user: "Offbi",
		creds: ['Sprite Artist & Animator', 'Branding', 'Character Designer'],
		desc: "BADASS FUCKING SKELETON BANGING A SHIELD",
		links: ['https://twitter.com/Officiallythat2']
	},
	{
		icon: "kiwi",
		user: "lexxiemow",
		creds: [
			'Composer of Tutorial',
			'Composer of Bopeebo',
			'Composer of Fresh',
			'Composer of Improbable Outset',
			'Composer of Try Harder',
			'Composer of Endless',
			'Composer of Cycles',
			'Composer of Milk',
			'Composer of dguy',
			'Composer of Lore'
		],
		desc: "W Plaps\n\nmusic but only sometimes, dont group me with the other funkers\n\nLet's play plappy bird",
		depth: 350,
		time: 2,
	},
	{
		icon: "bubu",
		user: "xyy",
		creds: [
			'Composer of Tutorial',
			'Composer of Bopeebo',
			'Composer of Endless',
			'Composer of Blammed'
		],
		desc: "the Fucking woods",
		links: ['https://youtube.com/@dasxyyy', 'https://twitter.com/dasxyyy']
	},
	{
		icon: "red",
		user: "RedTv53",
		creds: [
			'Composer of Dadbattle',
			'Voice of DD',
			'Vocal Help for Execution',
			'Vocalist of Execution',
			'Dirty Fucking Brit'
		],
		desc: "i love super mario. yeah thats right. thats my quote. also check out this cool video: https://youtu.be/BoGeRRN5AIc",
		links: ['https://www.youtube.com/@RedTv53', 'https://twitter.com/RedTv_53']
	},
	{
		icon: "ethan",
		user: "EthanTheDoodler",
		creds: [
			'Composer of Spookeez',
			'Composer of South',
			'Composer of Foolhardy',
			'Sound Designer'
		],
		desc: "Thanks for having me It was awesome Shout out to greg",
		links: [
			'https://www.youtube.com/channel/UCO3akF92JWqDAKUnGeqfrJw',
			'https://twitter.com/D00dlerEthan'
		]
	},
	{
		icon: "wrath",
		user: "Wrathstetic",
		creds: [
			'Composer of South',
			'Composer of Ghastly',
			'Composer of Monster',
			'Composer of Foolhardy',
			'Composer of Try Harder',
			'Vocalist of Game Over',
			'Vocalist of Stay Funky',
			'Voice of Chester and Pico',
			'Writer',
			'Sound Designer'
		],
		desc: "i still am the creator of twitter",
		depth: 120,
		time: 5,
		links: ['https://www.youtube.com/@wrathstetic', 'https://twitter.com/wrathstetic']
	},
	{
		icon: "wah",
		user: "TheWAHBox",
		creds: [
			'Composer of Pico',
			'Composer of Try Harder',
			'Composer of Milk',
                        'Composer of Game Over'
		],
		desc: "I'm wahbox.",
		links: ['https://www.youtube.com/@thewahbox']
	},
	{
		icon: "clover",
		user: "Cloverderus",
		creds: ['Composer of Philly Nice', 'Composer of Try Harder', 'Charter'],
		desc: "Run and hide.",
		links: ['https://youtube.com/@cloverderus', 'https://twitter.com/cloverderus']
	},
	{
		icon: "biddle",
		user: "Biddle3",
		creds: ['Composer of And'],
		desc: "my b3? remixed. sexy ladies? hit me up. on GLOOBY.",
		links: [
			'https://biddle3.newgrounds.com/',
			'https://www.youtube.com/@therealb3',
			'https://twitter.com/thedawg3_'
		]
	},
	{
		icon: "phi",
		user: "Philiplol",
		creds: ['Composer of Gettin Freaky', 'Composer of Legacy songs', 'Vocalist of Try Harder'],
		desc: "That's right, I'm trans now",
		links: ['https://bsky.app/profile/philiplol.bsky.social']
	},
	{
		icon: "selora",
		user: "Selora789",
		creds: [
			'Composer of Breakfast (Pause Menu)',
			'Composer of God Feast (Legacy)',
			'Composer of Gettin Freaky'
		],
		desc: "i am selors fuck that was a tpyo i am selora meow\n\nthis lil fnf mod butterfly effect'd me into stumbling into some of the nicest most supportive people in the world. i'll never be grateful enough for the friends i got to make with this team. anyway i gotta go play with my toys brb",
		depth: 120,
		time: 5,
		links: [
			'https://www.youtube.com/@selora789',
			'https://twitter.com/selora789',
			'https://bsky.app/profile/selora789.bsky.social'
		]
	},
	{
		icon: "qt",
		user: "qodax",
		creds: ['Week 0 Composer (Legacy)'],
		desc: ":boofholder:"
	},
	{
		icon: "gc",
		user: "gc",
		creds: ['Week 3 & 6 Composer (Legacy)'],
		desc: "their aids were covered by insurance"
	},
	{
		icon: "scrumbo",
		user: "scrumbo_",
		creds: ['Composer'],
		desc: "subscribe to EthanTheDoodler",
		links: ['https://www.youtube.com/@scrumbo_2096']
	},
	{
		icon: "fried",
		user: "Antinarious",
		creds: ['Composer'],
		desc: "super mario! real life? spaghetti.",
		links: ['https://www.youtube.com/@Antinarious', 'https://twitter.com/Antinarious']
	},
	{
		icon: "angel",
		user: "angelfaise",
		creds: ['Artist', 'Character Designer', 'Voice of MM & Lila'],
		desc: "Yeah can I get uhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh chicken numgetr",
		depth: 400,
		time: 5,
		links: ['https://twitter.com/angelfaIse']
	},
	{
		icon: "jimbogay",
		user: "JimboGames",
		creds: ['Concept Artist', 'Character Designer', 'Voice of Pump (Legacy)'],
		desc: "im jimbo, im games, play my games
		deacon has me locked in the basement making donkey kong",
		links: ['https://twitter.com/Jimb0Games']
	},
	{
		icon: "kloog",
		user: "KloogyBaboogy",
		creds: [
			'Concept Artist',
			'Character Designer',
			'Voice of Zephaniah & Zardy',
			'Voice of Skid (Legacy)'
		],
		desc: "Yadda yadda yadda I’m thankful for the chance to work on this mod it’s true but like wow it really opened up a lot of doors for me. I changed a lot personality wise, I made new friends, I got a partner and the mod is still going strong. I might not be nearly as into fnf anymore but it’s cool watching this project grow. Here’s to like a gajillion more dsides updates!",
		time: 5,
		depth: 250,
		links: ['https://www.youtube.com/@kloogybaboogy', 'https://twitter.com/kloogybaboogy']
	},
	{
		icon: "gf",
		user: "flyplague",
		creds: [
			'Character Designer',
			'Voice of Nene',
			'Married to D-Sides GF',
			"D-Sides GF's Wife",
			'However you want to put it, she likes D-GF.'
		],
		desc: "slapz my big bellaaaaaaaay ",
		links: ['https://twitter.com/flyplague']
	},
	{
		icon: "skl",
		user: "SKL (SuperKirbylover)",
		creds: ['Voice of GF', 'Character Designer', 'Sprite Artist & Animator'],
		desc: "hi guys - skl",
		links: [
			'https://superkirbylover.newgrounds.com/',
			'https://bsky.app/profile/superkirbylover.me'
		]
	},
	{
		icon: "funky",
		user: "FunkyBunny",
		creds: ['3D Modeler', 'Backing vocals', 'Mobian BF model'],
		desc: "At the moment my only contribution for this update is a backing line in Stay Funky, but D-Sides to me is one of the most creative projects I've ever seen and it's the absolute best in terms of making FNF fun and original again! I thank the whole team for giving me an opportunity to help them, and I look forward to this project's bright future!
		Also play VS Rephrase Redux!",
		depth: 250,
		time: 5,
		links: ['https://twitter.com/FunkiestBunny',]
	},
	{
		icon: "creambr",
		user: "StarNova (Cream.BR)",
		creds: ['Mobile Port'],
		desc: "I am someone... I am someone",
		links: [
			'https://youtube.com/@creambroficial',
			'https://twitter.com/StarNovaBR'
		]
	},
	{
		icon: "fnfbr",
		user: "FNF BR",
		creds: ['Mobile Port'],
		desc: "Brazil BRAZIL LET'S GO!!",
		links: [
			'https://youtube.com/@fnf-br'
		]
	},
	{
		icon: "dechis",
		user: "Dechis",
		creds: ['Special Thanks (Mobile Port)'],
		desc: "Amogus",
		links: [
			'https://youtube.com/@deechiss'
		]
	},
	{
		icon: "contributors",
		user: "Contributors",
		creds: [
			'Data5',
			'FredrickFunny',
			'lemonaid24',
			'Srife5'
			'peakjuggler',
			'moxxie',
			'NebulaTheZorua',
			'Gojira Darko',
			'Clappers46',
			'blackberri',
			'Rareblin',
			'LancExists',
			'BenzBT',
			'Greenstranger',
			'SrPelo',
			'BBPanzu',
			'Weedeet',
			'JcJack',
			'Corven_03',
			'Beethovenus',
			'RecD'
		],
		depth: 380,
		time: 5,
		desc: "Thanks to everybody that contributed to this project!"
	},
	{
		icon: "owners",
		user: "Owners",
		creds: [
			"FNF Characters by the Funkin' Crew",
			"Pico's School by Tom Fulp",
			"Spooky Month by SrPelo",
			"Madness Combat by Krinkels",
			"Whitty by sock.clip",
			"Zardy's Maze by SwankyBox",
			"SEGA Characters by SEGA",
			"Nintendo Characters by Nintendo",
			"Soulless Saga by JoeDoughboi",
			"Sunky by LooneyDude",
			"FNAF by Scott Cawthon",
			"Matpat by Linda Patrick",
			"Alien Hominid by The Behemoth",
			"ENA Series by Joel Guerra",
			"Graffiti Groovin' Characters by Rechiru",
			"Dad N' Me by Tom Fulp & Dan Paladin",
			"Shaggy by Hannah Barbera",
			"Nikku by Saruky",
			"Licorice by Snowy",
			"Sky by Dra9onSlayer5 and Alexander0110_"
			"Lord X model by Dedmandood3030"
		],
		desc: "Credits to all original composers and mod teams featured / remixed in this mod!",
		depth: 520,
		time: 3,
		links: ['https://youtube.com/@duskiewhy']
	},
	{
		icon: "special",
		user: "Special Thanks",
		creds: [
			// friend groups
			'Goop Troop',
			'Purple´s Hub World',
			// mod teams
			'Studio Hopscotch',
			'Mario´s Madness Team',
			'Funkin At Freddy´s Team',
			// fan servers
			'Popeye´s Discord Server',
			'Funhouse Discord Server',
			'Inverted Fate Discord Server',
			// individuals
			'Penkaru',
			'Nowhereman',
			'Ratto',
			'TheWinterReaper',
			'Nitr0cyti',
			// artists
			'Jane Remover',
			'Tyler the Creator',
			'Joey Valence & Brae',
			'2hollis',
			'Noah for playing the build',
			'Rozebud for owning the beach house',
			'and...not you! WE HATE YOU!'
		],
		depth: 525,
		time: 5,
		desc: "JK. Thanks to everybody that supported us!"
	}
	
];

var iconGrp:FlxSpriteGroup;
var curLinks = [];
var curSelected = 0;
var txtCam:FlxCamera;

/**
 * [onLoad()]
 * Runs on loading of the script.
 * 
 * In this script:
 *  Creates all graphics shown in the menu.
 *  Changes the discord status. 
 *  If the player hasn't seen this menu, marks this sequence as completed in the save data.
*/
function onCreate() {
	persistentDraw = true;
	persistentUpdate = true;

	DiscordClient.changePresence('Browsing the credits');

	bg = new FlxSprite().loadGraphic(Paths.image('menus/credits/bg'));
	add(bg);
	add(new FlxSprite().loadGraphic(Paths.image('menus/credits/dark border')));

	sq2 = new FlxBackdrop(Paths.image('menus/credits/movie'), FlxAxes.Y, 20, -2);
	sq2.y += 200;
	add(sq2);

	txtbox = new FlxSprite(660, 100).loadGraphic(Paths.image('menus/credits/text box'));
	add(txtbox);

	txtCam = new FlxCamera(txtbox.x, txtbox.y + 45, txtbox.width, txtbox.height - 64);
	txtCam.bgColor = 0x0;
	FlxG.cameras.add(txtCam, false);

	title = new FlxText(0, 20);
	title.setFormat(Paths.font('aller.ttf'), 40, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.PURPLE);
	title.borderSize = 3;
	title.camera = txtCam;
	add(title);

	description = new FlxText();
	description.setFormat(Paths.font('candy.otf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
	description.setPosition(10, 100);
	description.autoSize = false;
	description.fieldWidth = txtbox.width - 20;
	description.camera = txtCam;
	add(description);

	add(new FlxSprite().loadGraphic(Paths.image('menus/credits/borders')));

	sq1 = new FlxBackdrop(Paths.image('menus/credits/movie'), FlxAxes.Y, 20, -2);
	add(sq1);
	brand = new FlxSprite(120, -60);
	brand.frames = Paths.getSparrowAtlas('menus/credits/txt');
	brand.animation.addByPrefix('loop', 'projector loop', 24, true);
	brand.animation.play('loop');
	add(brand);

	camC = new FlxCamera(0, 0, 1280, brand.height + 60 + (300 * credits.length));
	camC.bgColor = 0x0;
	FlxG.cameras.add(camC, false);

	iconGrp = new FlxSpriteGroup(0, 50);
	add(iconGrp);

	// inserts the oat gang's credits if you unlocked soretro
	if(FlxG.save.data.unlockedHim){
		credits.insert(credits.length - 1, {
		icon: "oat",
		user: "Oat Gang",
		creds: ['Marketplier', 'Salesman999', 'Icey131', 'JoggingScout (LECTROA)', 'Gary Gilbenson',  'DuskieWhy', 'FredrickFunny'],
		desc: "@re_thinkin Yo.\n\nCreators of SORETRO.",
		depth: 50,
		time: 2
	});
	}

		
	var rN = -1;
	var aRN = 0;
	for (i in 0...credits.length) {
		var c = credits[i];
		rN += 1;
		if (rN >= 4) {
			rN = 0;
			aRN += 1;
		}

		var icon = new FlxSprite().loadGraphic(Paths.image('menus/credits/icons/' + c.icon));
		icon.scale.set(0.375, 0.375);
		icon.updateHitbox();
		icon.setPosition(145 + (130 * rN), 140 + (130 * aRN));
		icon.antialiasing = true;
		icon.ID = i;
		icon.camera = camC;
		iconGrp.add(icon);
	}

	ng = new FlxSprite().loadGraphic(Paths.image('menus/credits/links/ng'));
	ng.scale.set(0.25, 0.25);
	ng.updateHitbox();
	ng.antialiasing = true;
	add(ng);
	bsky = new FlxSprite().loadGraphic(Paths.image('menus/credits/links/bluesky'));
	bsky.scale.set(0.25, 0.25);
	bsky.updateHitbox();
	bsky.antialiasing = true;
	add(bsky);
	porn = new FlxSprite().loadGraphic(Paths.image('menus/credits/links/porn'));
	porn.scale.set(0.25, 0.25);
	porn.updateHitbox();
	porn.antialiasing = true;
	add(porn);
	twit = new FlxSprite().loadGraphic(Paths.image('menus/credits/links/twitter'));
	twit.scale.set(0.25, 0.25);
	twit.updateHitbox();
	twit.antialiasing = true;
	add(twit);
	yt = new FlxSprite().loadGraphic(Paths.image('menus/credits/links/yt'));
	yt.scale.set(0.25, 0.25);
	yt.updateHitbox();
	yt.antialiasing = true;
	add(yt);

	updateTxt(0);

	xButton = new FlxSprite(1280, 20).loadGraphic(Paths.image('UI/window/x'));
	xButton.scale.set(0.5, 0.5);
	xButton.updateHitbox();
	xButton.x = 1280 - xButton.width - 10;
	add(xButton);

	PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
	FlxG.mouse.visible = true;

	PluginsManager.callPluginFunc('Utils', 'saveFix', []);

    var save = FlxG.save.data.completedMenuShit.get('credits');
    if(save == false || save == null){
        FlxG.save.data.completedMenuShit.set('credits', true);
        FlxG.save.data.completionPercent += 1.4;

        FlxG.save.flush();
    }
    
    addVirtualPad(MobileDPadMode.UP_DOWN, MobileActionMode.NONE);
	addVirtualPadCamera();

}

var limits = [40, -740];
var timer = 0;
var dir = 1;
var depth = 50;
var time = 4;
var ity = 50;
var scrollTxt:Bool = false;


/**
 * [onUpdate(elapsed)]
 * Run on every frame update.
 
 * @param elapsed
 * Floating-point value that holds the second-value between the last frame update of the game.
 * Also known as a frame-delta.
  
 * In this script
 *  Handles all inputs
 *  Controls all graphic coloring, positioning, etc
 */
function onUpdate(elapsed) {
	if (controls.BACK) {
		FlxG.sound.play(Paths.sound("cancelMenu"));
		FlxG.switchState(() -> new MainMenuState());
	}

	sq1.x = 10;
	sq1.y += 1 * (60 * elapsed);
	sq2.x = FlxG.width - (sq2.width + 20);
	sq2.y += 1.25 * (60 * elapsed);

	if (FlxG.mouse.overlaps(xButton)) {
		xButton.loadGraphic(Paths.image("UI/window/x2"));

		if (FlxG.mouse.justPressed) {
			FlxG.sound.play(Paths.sound("cancelMenu"));
			FlxG.switchState(() -> new MainMenuState());
		}
	} else
		xButton.loadGraphic(Paths.image("UI/window/x"));

	for (i in iconGrp.members) {
		if (i.ID == curSelected)
			i.color = FlxColor.WHITE;
		else if (FlxG.mouse.overlaps(i)) {
			i.color = 0xFFa1a1a1;
			if (FlxG.mouse.justPressed) {
				curSelected = i.ID;
				updateTxt(curSelected);
			}

			break;
		} else
			i.color = 0xFF4a4848;
	}

	ity += (FlxG.mouse.wheel * 25);
	if (controls.UI_UP || virtualPad.buttonUp.pressed)
		ity += 10 * (60 * elapsed);

	if (controls.UI_DOWN || virtualPad.buttonDown.pressed)
		ity -= 10 * (60 * elapsed);

	if (ity >= limits[0])
		ity = limits[0];
	if (ity <= limits[1])
		ity = limits[1];

	if (FlxG.mouse.overlaps(brand) && FlxG.mouse.justPressed)
		FlxG.switchState(new ScriptedState('CreditsVideo'));

	iconGrp.y = FlxMath.lerp(iconGrp.y, ity, FlxMath.bound(elapsed * 16, 0, 1));
	brand.y = iconGrp.y - 90;

	if (curLinks.length >= 1) {
		for (i in curLinks) {
			if (FlxG.mouse.overlaps(i)) {
				i.color = FlxColor.WHITE;
				if (FlxG.mouse.justPressed)
					FlxG.openURL(credits[curSelected].links[i.ID]);

				break;
			} else
				i.color = 0xFFa1a1a1;
		}
	}

	var overlaps = [xButton, brand];
	for (i in curLinks)
		overlaps.push(i);
	for (i in iconGrp) {
		if (i.ID != curSelected)
			overlaps.push(i);
	}

	for (i in overlaps) {
		if (i != null) {
			if (FlxG.mouse.overlaps(i)) {
				PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);
				break;
			} else
				PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
		}
	}

	if (scrollTxt) {
		timer += 0.05 * (60 * elapsed);
		if (timer > time) {
			txtCam.scroll.y += 0.5 * (dir * 60 * elapsed);
			if (txtCam.scroll.y > depth && dir == 1 || txtCam.scroll.y <= 0 && dir == -1) {
				timer = 0;
				dir *= -1;
			}
		}
	}
}

var id2 = -1;

/**
 * [updateTxt()]
 * Updates the text for credit messages, username, etc.
 * Also handles if the text scrolls or not, alongside changing the links currently used
 * 
 * @param id
 * Integer id of the location of the username in the credits array.
 **/
function updateTxt(id) {
	var c = credits[id];

	description.text = '';
	for (i in c.creds)
		description.text += "-" + i + "\n";
	description.text += '\n "' + c.desc + '"';

	if (c.height != null)
		description.fieldHeight = c.height;
	else
		description.fieldHeight = 1000;

	scrollTxt = false;
	timer = 0;
	txtCam.scroll.y = 0;
	if (c.depth > 0) {
		scrollTxt = true;
		time = c.time;
		depth = c.depth;
	}

	// links
	id2 = -1;
	curLinks = [];
	for (i in [ng, bsky, porn, yt, twit])
		i.visible = false;
	if (c.links != null) {
		for (i in c.links) {
			if (StringTools.contains(i, 'm4SF6jzrrI4')){
				curLinks.push(porn);
				break;
			}
			if (StringTools.contains(i, 'youtube'))
				curLinks.push(yt);
			if (StringTools.contains(i, 'twitter'))
				curLinks.push(twit);
			if (StringTools.contains(i, 'newgrounds'))
				curLinks.push(ng);
			if (StringTools.contains(i, 'bsky'))
				curLinks.push(bsky);
		}
		for (i in curLinks) {
			id2 += 1;
			i.setPosition(((txtbox.x + txtbox.width) - (60 * id2) - 50), txtbox.y + txtbox.height);
			i.ID = id2;
			i.visible = true;
		}
	}

	title.text = c.user;
	title.x = (txtCam.width - title.width) / 2;
}
